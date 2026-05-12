"""Editability metric — fraction of dimensions bound to named parameters.

CRAFT's JSON IR preserves symbolic expressions like `outer_diameter/2`. Most
fine-tuned generators bake numeric values at training time and emit literals.
This metric counts the ratio of parameter references to numeric literals
across the dimensional fields of the generated code:

    editability = parameter_refs / (parameter_refs + numeric_literals)

We support OpenSCAD (CRAFT's primary output) and CadQuery (their model's
output). Strings, units of measure, and loop indices are excluded by
deliberate scoping (we only count constructor/method argument positions).

Limitations: a string-level heuristic — it doesn't know what's a "dimension"
vs. a thing like `$fn=64`. We mitigate by excluding `$fn`, `$fa`, `$fs`,
`fn=`, and common iteration indices.
"""

from __future__ import annotations

import re
from dataclasses import dataclass
from pathlib import Path
from typing import Literal


@dataclass
class EditabilityResult:
    editability: float
    parameter_refs: int
    numeric_literals: int
    language: str


_NUMERIC_RE = re.compile(r"(?<![A-Za-z_])-?\d+(?:\.\d+)?(?:[eE][+-]?\d+)?")
# Single-token identifiers used as dimensions: alphanumeric + underscore, not a keyword.
_IDENT_RE = re.compile(r"[A-Za-z_][A-Za-z_0-9]*")
# Excluded identifiers: OpenSCAD/CadQuery built-ins, loop indices, common library names.
_EXCLUDED_IDENTS = {
    "true", "false", "True", "False", "None", "null",
    "and", "or", "not", "in", "is", "if", "else", "elif", "for", "while",
    "return", "def", "from", "import", "as", "with", "try", "except", "raise",
    "module", "function", "use", "include", "let",
    "i", "j", "k", "x", "y", "z",
    "cq", "cadquery", "math", "np", "numpy",
    "fn", "fa", "fs",
}
_DOLLAR_RE = re.compile(r"\$[A-Za-z_]\w*")


def _detect_language(code: str, hint: str | None) -> Literal["openscad", "cadquery", "unknown"]:
    if hint == "openscad":
        return "openscad"
    if hint == "cadquery":
        return "cadquery"
    if "cq.Workplane" in code or "import cadquery" in code:
        return "cadquery"
    if "module " in code or "$fn" in code or ".scad" in code:
        return "openscad"
    return "unknown"


def _count_in_arg_positions_openscad(code: str) -> tuple[int, int]:
    """Heuristic: count tokens that appear inside () after a known construct.

    For OpenSCAD we look at calls like cube(...), cylinder(...), translate(...),
    rotate(...), linear_extrude(...), etc., and count parameters vs. literals
    only inside their argument lists.
    """
    constructs = (
        "cube", "sphere", "cylinder", "polygon", "polyhedron",
        "translate", "rotate", "scale", "mirror", "resize",
        "linear_extrude", "rotate_extrude", "hull", "minkowski",
        "offset", "circle", "square", "text",
    )
    param_refs = 0
    literals = 0
    # find calls
    for construct in constructs:
        pattern = re.compile(rf"\b{construct}\s*\(([^)]*)\)")
        for m in pattern.finditer(code):
            args = m.group(1)
            # strip $fn=… and similar special-vars from counting
            args = _DOLLAR_RE.sub("", args)
            literals += len(_NUMERIC_RE.findall(args))
            for ident in _IDENT_RE.findall(args):
                if ident not in _EXCLUDED_IDENTS:
                    param_refs += 1
    return param_refs, literals


def _count_in_arg_positions_cadquery(code: str) -> tuple[int, int]:
    """For CadQuery we look at method calls on Workplane objects."""
    methods = (
        "rect", "circle", "polygon", "box", "extrude", "cutBlind",
        "hole", "cboreHole", "cskHole", "chamfer", "fillet",
        "translate", "rotate", "rotateAboutCenter", "transformed",
        "center", "moveTo", "lineTo", "polyline",
        "revolve", "loft", "sweep", "workplane", "Workplane",
    )
    param_refs = 0
    literals = 0
    for method in methods:
        pattern = re.compile(rf"\.?{method}\s*\(([^)]*)\)")
        for m in pattern.finditer(code):
            args = m.group(1)
            literals += len(_NUMERIC_RE.findall(args))
            for ident in _IDENT_RE.findall(args):
                if ident not in _EXCLUDED_IDENTS:
                    param_refs += 1
    return param_refs, literals


def editability_for_code(
    code: str | Path,
    language_hint: str | None = None,
) -> EditabilityResult:
    """Compute the editability ratio for a generated source file."""
    # Path vs. inline source: a Path object, or a short single-line string
    # that resolves to an existing file. Anything multi-line / very long is
    # treated as inline source code.
    text: str
    if isinstance(code, Path):
        text = code.read_text(encoding="utf-8", errors="replace")
    elif isinstance(code, str) and "\n" not in code and len(code) < 4096:
        try:
            p = Path(code)
            text = p.read_text(encoding="utf-8", errors="replace") if p.exists() else code
        except (OSError, ValueError):
            text = code
    else:
        text = str(code)

    lang = _detect_language(text, language_hint)
    if lang == "cadquery":
        param_refs, literals = _count_in_arg_positions_cadquery(text)
    else:
        param_refs, literals = _count_in_arg_positions_openscad(text)

    total = param_refs + literals
    edit = (param_refs / total) if total > 0 else 0.0
    return EditabilityResult(
        editability=float(edit),
        parameter_refs=int(param_refs),
        numeric_literals=int(literals),
        language=lang,
    )
