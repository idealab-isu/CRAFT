"""Build benchmark_ground_truth_v2.json from the 485 successfully-rendered SCAD files.

Approach:

1. For every `<family>.scad` (singular) under NopSCADlib/vitamins/ we parse the
   accessor functions like `function bb_bore(type) = type[1]; //! Internal diameter`
   to obtain a canonical, ordered list of `(field_name, docstring)` per family.

2. For every `<family>s.scad` (plural) we parse top-level array assignments such
   as `BB608 = ["608", 8, 22, 7, ...]` — including multi-line ones — to obtain
   a mapping `type_constant -> [raw_value_0, raw_value_1, ...]`.

3. For each of the 485 successful renders we read the header comments of the
   SCAD file, look up its type constant in the constant table, align the values
   against the accessor schema, and synthesise a natural-language prompt that
   embeds the actual geometry with units.

The prompt templates are hand-authored per family by me (Claude Opus 4.7).
When no family-specific template applies the builder falls back to a generic
"<family>: field: value, ..." prompt so nothing is ever silently dropped.
"""

from __future__ import annotations

import json
import re
from pathlib import Path

NOP = Path.home() / "Documents" / "OpenSCAD" / "libraries" / "nopscadlib"
VIT = NOP / "vitamins"
GT = Path("/Users/mohd7/Local/CRAFT/Experimentation/GroundTruth")
SCAD_DIR = GT / "scad"
STL_DIR = GT / "stl"
OUT = GT / "benchmark_ground_truth_v2.json"

# Map our on-disk family name to the NopSCADlib module base name.
# Most are identical; batterie -> battery is the notable exception.
FAMILY_TO_MODULE: dict[str, str] = {
    "batterie": "battery",
}

# Some plural file names are irregular (y -> ies) so we look them up directly.
FAMILY_TO_CONSTANTS_FILE: dict[str, str] = {
    "batterie": "batteries.scad",
}


def family_module(family: str) -> str:
    return FAMILY_TO_MODULE.get(family, family)


def family_constants_file(family: str) -> str:
    if family in FAMILY_TO_CONSTANTS_FILE:
        return FAMILY_TO_CONSTANTS_FILE[family]
    return f"{family_module(family)}s.scad"


# ---------------------------------------------------------------------------
# Parse accessor files -> per-family schema
# ---------------------------------------------------------------------------

ACCESSOR_RE = re.compile(
    r"^function\s+([A-Za-z_0-9][A-Za-z0-9_]*)\s*\(\s*type\s*\)\s*=\s*type\s*\[\s*(\d+)\s*\]\s*"
    r"(?P<div>/\s*2)?\s*;\s*(?://!\s*(.*))?$"
)


def _semantic_name(short: str, halved: bool) -> str:
    """Translate an accessor's short name to a field label describing the raw value.

    When the accessor halves the raw value (`radius = type[N]/2`) the raw value
    is actually the diameter, so we rename accordingly.  Likewise for
    inner/outer-radius shorthand.
    """
    if halved:
        if short == "radius":
            return "diameter"
        if short.endswith("_radius"):
            return short[: -len("_radius")] + "_diameter"
        if short == "ir":
            return "id"
        if short == "or":
            return "od"
        return short + "_x2"
    return short


def parse_accessors(path: Path) -> list[tuple[int, str, str]]:
    """Return a list of (index, field_name, doc) tuples sorted by index.

    Only direct `type[N]` accessors whose function name starts with the
    dominant (most frequent) prefix in the file are considered.  Index 0 is
    always present; if no accessor explicitly targets it we synthesise a
    `name` entry because every NopSCADlib type array starts with its name.
    """
    if not path.exists():
        return []

    raw_hits: list[tuple[str, int, bool, str]] = []
    for raw in path.read_text().splitlines():
        m = ACCESSOR_RE.match(raw.strip())
        if not m:
            continue
        raw_hits.append(
            (m.group(1), int(m.group(2)), bool(m.group("div")), (m.group(4) or "").strip())
        )
    if not raw_hits:
        return [(0, "name", "Type name / code")]

    from collections import Counter
    prefixes = Counter()
    for fn, _, _, _ in raw_hits:
        m = re.match(r"([a-z0-9]+_)", fn)
        if m:
            prefixes[m.group(1)] += 1
    dom = prefixes.most_common(1)[0][0] if prefixes else ""

    schema: dict[int, tuple[str, str]] = {}
    for fn, idx, halved, doc in raw_hits:
        if dom and not fn.startswith(dom):
            continue
        short = fn[len(dom):] if dom else fn
        short = _semantic_name(short, halved)
        schema.setdefault(idx, (short, doc))
    # If an existing entry is already named 'name', rename the synthetic one.
    if any(v[0] == "name" for v in schema.values()) and 0 not in schema:
        schema[0] = ("code", "Type identifier / code")
    else:
        schema.setdefault(0, ("name", "Type name / code"))
    return [(i, *schema[i]) for i in sorted(schema)]


# ---------------------------------------------------------------------------
# Parse constants files -> {type_constant: [raw_value, ...]}
# ---------------------------------------------------------------------------

CONSTANT_RE = re.compile(
    r"^(?P<name>[A-Z_][A-Za-z0-9_]*)\s*=\s*\[(?P<body>.*?)\]\s*;",
    re.DOTALL | re.MULTILINE,
)


def split_top_level(body: str) -> list[str]:
    """Split a comma-separated SCAD vector body, respecting nested [] and ()."""
    parts: list[str] = []
    depth = 0
    buf: list[str] = []
    in_str = False
    escape = False
    for ch in body:
        if escape:
            buf.append(ch)
            escape = False
            continue
        if ch == "\\":
            buf.append(ch)
            escape = True
            continue
        if ch == '"':
            in_str = not in_str
            buf.append(ch)
            continue
        if in_str:
            buf.append(ch)
            continue
        if ch in "[(":
            depth += 1
            buf.append(ch)
        elif ch in "])":
            depth -= 1
            buf.append(ch)
        elif ch == "," and depth == 0:
            parts.append("".join(buf).strip())
            buf = []
        else:
            buf.append(ch)
    tail = "".join(buf).strip()
    if tail:
        parts.append(tail)
    # Drop trailing line comments from each part
    cleaned = []
    for p in parts:
        p = re.sub(r"//.*$", "", p, flags=re.MULTILINE).strip()
        p = re.sub(r"/\*.*?\*/", "", p, flags=re.DOTALL).strip()
        cleaned.append(p)
    return cleaned


def strip_block_comments(src: str) -> str:
    return re.sub(r"/\*.*?\*/", "", src, flags=re.DOTALL)


def parse_constants(path: Path) -> dict[str, list[str]]:
    if not path.exists():
        return {}
    src = strip_block_comments(path.read_text())
    # Also strip // line comments before the regex scan because they can break
    # the bracket-matching if they contain ']'.  But keep them elsewhere.
    lines = []
    for line in src.splitlines():
        # Remove // comments (but not inside strings). Simple heuristic: cut at
        # the first // that is not inside quotes.
        in_s = False
        out = []
        i = 0
        while i < len(line):
            c = line[i]
            if c == '"':
                in_s = not in_s
                out.append(c)
            elif not in_s and c == "/" and i + 1 < len(line) and line[i + 1] == "/":
                break
            else:
                out.append(c)
            i += 1
        lines.append("".join(out))
    src = "\n".join(lines)

    results: dict[str, list[str]] = {}
    # Use a manual bracket walker because constants can span multiple lines and
    # contain nested []
    i = 0
    while i < len(src):
        m = re.match(r"\s*([A-Z_][A-Za-z0-9_]*)\s*=\s*\[", src[i:])
        if not m:
            i += 1
            continue
        name = m.group(1)
        start = i + m.end()  # position just after '['
        depth = 1
        j = start
        in_s = False
        escape = False
        while j < len(src) and depth > 0:
            c = src[j]
            if escape:
                escape = False
            elif c == "\\":
                escape = True
            elif c == '"':
                in_s = not in_s
            elif not in_s:
                if c == "[":
                    depth += 1
                elif c == "]":
                    depth -= 1
                    if depth == 0:
                        break
            j += 1
        if depth != 0:
            i = start
            continue
        body = src[start:j]
        parts = split_top_level(body)
        results[name] = parts
        k = j + 1
        while k < len(src) and src[k] in " \t\n;":
            k += 1
        i = k
    return results


# Patch: rewrite the bracket walker above via a helper that correctly handles
# backslash-escaped quotes inside string literals.


# ---------------------------------------------------------------------------
# Read per-component SCAD file header
# ---------------------------------------------------------------------------

HEADER_RE = {
    "ground_truth": re.compile(r"^// Ground truth:\s*(.*)$", re.MULTILINE),
    "family": re.compile(r"^// Family:\s*(.*)$", re.MULTILINE),
    "type_constant": re.compile(r"^// Type constant:\s*(.*)$", re.MULTILINE),
    "module_call": re.compile(r"^// Module call:\s*(.*)$", re.MULTILINE),
    "description": re.compile(r"^// Description:\s*(.*)$", re.MULTILINE),
}


def parse_scad_header(path: Path) -> dict[str, str]:
    src = path.read_text()
    out: dict[str, str] = {}
    for k, rx in HEADER_RE.items():
        m = rx.search(src)
        if m:
            out[k] = m.group(1).strip()
    return out


# ---------------------------------------------------------------------------
# Complexity metrics (lightweight, on the SCAD source)
# ---------------------------------------------------------------------------

PRIMITIVES = {"cube", "sphere", "cylinder", "polyhedron", "square", "circle", "polygon", "text"}
BOOL_OPS = {"union", "difference", "intersection", "hull", "minkowski"}
TRANSFORMS = {"translate", "rotate", "scale", "mirror", "resize", "multmatrix", "offset"}


def compute_complexity(scad_src: str) -> dict[str, int | float]:
    # Strip comments for a cleaner count
    no_block = re.sub(r"/\*.*?\*/", "", scad_src, flags=re.DOTALL)
    no_line = re.sub(r"//[^\n]*", "", no_block)
    tokens = re.findall(r"[A-Za-z_][A-Za-z0-9_]*", no_line)

    primitive_count = sum(t in PRIMITIVES for t in tokens)
    boolean_op_count = sum(t in BOOL_OPS for t in tokens)
    transform_count = sum(t in TRANSFORMS for t in tokens)
    sub_module_calls = len(re.findall(r"([A-Za-z_][A-Za-z0-9_]*)\s*\(", no_line))
    lines_of_code = sum(1 for ln in no_line.splitlines() if ln.strip())

    # Rough CSG depth: maximum nesting of boolean-op braces
    depth = cur = 0
    csg_tokens = []
    for m in re.finditer(r"([A-Za-z_][A-Za-z0-9_]*)\s*\(|[{}]", no_line):
        tok = m.group(0)
        if tok == "{":
            cur += 1
            depth = max(depth, cur)
        elif tok == "}":
            cur = max(0, cur - 1)
        else:
            name = m.group(1)
            if name in BOOL_OPS:
                csg_tokens.append(name)

    complexity_score = (
        primitive_count * 0.5
        + boolean_op_count * 1.5
        + transform_count * 0.5
        + sub_module_calls * 0.5
    )

    return {
        "primitive_count": primitive_count,
        "boolean_op_count": boolean_op_count,
        "csg_depth": depth,
        "transform_count": transform_count,
        "sub_module_calls": sub_module_calls,
        "lines_of_code": lines_of_code,
        "complexity_score": round(complexity_score, 2),
    }


# ---------------------------------------------------------------------------
# Prompt generation: family-aware natural-language synthesis.
# ---------------------------------------------------------------------------

_VOWEL_SOUND_FIRST = re.compile(
    r"\b([Aa]) (?=("
    r"[AEIOUaeiou]"                      # obvious written vowels
    r"|[FHLMNRSX][A-Z0-9]"               # letter-abbreviations starting with a
                                         # consonant that sounds like a vowel
                                         # (M3, MR63, LCD, NEMA, SK10, FIT...)
    r"|[FHLMNRSX][a-z]*[A-Z0-9]"         # slight variations like "Mtec"
    r"|8(?:[\s.,]|$|\d)"                  # 8, 80, 800...
    r"|11(?:[\s.,]|$|\d)"                 # 11, 11.5...
    r"|18(?:[\s.,]|$|\d)"                 # 18, 18.x...
    r"|80\d*(?:[\s.,]|$)"                 # 80, 800, 8000 (eighty, eight hundred)
    r"|open|honest|hour"
    r"))"
)


def fix_articles(text: str) -> str:
    return _VOWEL_SOUND_FIRST.sub(
        lambda m: ("A" if m.group(1) == "A" else "a") + "n ", text
    )


def fmt_num(v: str | None) -> str | None:
    """Pretty-print a raw SCAD scalar as a short string, if it parses."""
    if v is None:
        return None
    v = v.strip()
    if not v:
        return None
    # Strip outer quotes from strings
    if v.startswith('"') and v.endswith('"'):
        return v[1:-1]
    # Evaluate simple numeric literals
    try:
        f = float(v)
        if f.is_integer():
            return str(int(f))
        return f"{f:g}"
    except ValueError:
        pass
    return v


def build_field_names(schema: list[tuple[int, str, str]], n_values: int) -> list[str]:
    """One field name per value, indexed by position (filling gaps)."""
    by_idx = {i: name for i, name, _ in schema}
    return [by_idx.get(i, f"_field_{i}") for i in range(n_values)]


def fields_dict(schema: list[tuple[int, str, str]], values: list[str]) -> dict[str, str]:
    """Map canonical field name -> raw value, keyed by accessor index."""
    names = build_field_names(schema, len(values))
    return {name: val for name, val in zip(names, values)}


def get(fields: dict[str, str], *keys: str) -> str | None:
    for k in keys:
        if k in fields:
            v = fmt_num(fields[k])
            if v not in (None, "", "0"):
                return v
    return None


def get_raw(fields: dict[str, str], *keys: str) -> str | None:
    for k in keys:
        if k in fields:
            v = fields[k].strip()
            if v:
                return v
    return None


# ---------------------------------------------------------------------------
# Helpers for dimension-only prompts.
#
# User directive: the prompt must describe a component purely in terms of its
# geometry and family. No catalog / model / part numbers, so that the prompt
# alone — fed into the same OpenSCAD module family — should reproduce the
# exact same render. Each prompt therefore emits a generic family noun + a
# compact list of the numeric fields that the NopSCADlib module consumes.
# ---------------------------------------------------------------------------


def _parse_vec(raw: str | None, strict: bool = False) -> list[float | None] | None:
    """Split a SCAD vector literal like '[1, 2.5, 3]' into elements. Non-
    numeric entries (nested vectors, function calls, strings) are returned as
    `None` unless `strict=True`, in which case the whole parse fails."""
    if not raw:
        return None
    s = raw.strip()
    if not (s.startswith("[") and s.endswith("]")):
        return None
    inner = s[1:-1]
    depth = 0
    cur = ""
    parts: list[str] = []
    in_s = False
    escape = False
    for ch in inner:
        if escape:
            cur += ch; escape = False; continue
        if ch == "\\":
            cur += ch; escape = True; continue
        if ch == '"':
            in_s = not in_s; cur += ch; continue
        if not in_s:
            if ch in "[(":
                depth += 1
            elif ch in "])":
                depth -= 1
            if ch == "," and depth == 0:
                parts.append(cur); cur = ""; continue
        cur += ch
    if cur.strip():
        parts.append(cur)
    out: list[float | None] = []
    for p in parts:
        v = _eval_scad_scalar(p)
        try:
            out.append(float(v) if v is not None else None)
        except (TypeError, ValueError):
            if strict:
                return None
            out.append(None)
    return out


def _fmt(v: float | None) -> str | None:
    if v is None:
        return None
    return f"{v:g}"


def _emit(dims: list[str]) -> str:
    return (": " + ", ".join(dims) + ".") if dims else "."


_INCH_RE = re.compile(r"inch\(\s*(\d+)\s*/\s*(\d+)\s*\)|inch\(\s*(\d+(?:\.\d+)?)\s*\)")


def _eval_scad_scalar(raw: str | None) -> str | None:
    """Try harder than fmt_num to turn a SCAD expression into a plain number.
    Currently handles `inch(x)` / `inch(a/b)` by converting to millimetres."""
    if raw is None:
        return None
    s = raw.strip()
    if not s:
        return None
    if s.startswith('"') and s.endswith('"'):
        return s[1:-1]
    m = _INCH_RE.fullmatch(s)
    if m:
        if m.group(1) and m.group(2):
            val = float(m.group(1)) / float(m.group(2)) * 25.4
        else:
            val = float(m.group(3)) * 25.4
        return f"{val:g}"
    try:
        f = float(s)
        return str(int(f)) if f.is_integer() else f"{f:g}"
    except ValueError:
        return None


def num(fields: dict[str, str], *keys: str) -> str | None:
    """Like `get`, but only returns strictly numeric values (including things
    like `inch(1/4)` that can be evaluated). Useful when you want to drop
    non-numeric fallbacks such as bare identifiers."""
    for k in keys:
        if k in fields:
            v = _eval_scad_scalar(fields[k])
            if v not in (None, "", "0"):
                return v
    return None


def prompt_ball_bearing(f, c, d):
    bore = get(f, "bore"); od = get(f, "diameter"); w = get(f, "width")
    fd = get(f, "flange_diameter"); fw = get(f, "flange_width")
    dims = []
    if bore: dims.append(f"{bore} mm bore")
    if od:   dims.append(f"{od} mm outer diameter")
    if w:    dims.append(f"{w} mm width")
    if fd:   dims.append(f"{fd} mm flange diameter")
    if fw:   dims.append(f"{fw} mm flange width")
    head = "A flanged ball bearing" if fd else "A ball bearing"
    return head + _emit(dims)


_SCREW_STYLE = {
    "cap": "socket-head cap screw",
    "cs_cap": "countersunk socket-head cap screw",
    "cs_cap_screw": "countersunk socket-head cap screw",
    "dome": "socket dome-head screw",
    "pan": "pan-head machine screw",
    "hex": "hex-head bolt",
    "grub": "grub (set) screw",
    "low_cap": "low-profile socket-head cap screw",
    "shoulder": "shoulder screw",
}


def prompt_screw(f, c, d):
    head = "machine screw"
    for k, v in _SCREW_STYLE.items():
        if c.endswith(f"_{k}_screw") or c.endswith(f"_{k}") or c.endswith(f"_{k}screw"):
            head = v; break
    if c.startswith(("No2", "No4", "No6", "No8", "No632")):
        head = "wood / self-tapping screw"
    dia = get(f, "diameter")
    hd = get(f, "head_diameter")
    hh = get(f, "head_height")
    thr = get(f, "max_thread")
    saf = get(f, "socket_af")
    dims = []
    if dia: dims.append(f"{dia} mm thread diameter")
    if hd:  dims.append(f"{hd} mm head diameter")
    if hh:  dims.append(f"{hh} mm head height")
    if saf: dims.append(f"{saf} mm hex-socket across flats")
    if thr: dims.append(f"up to {thr} mm thread length")
    return f"A {head}" + _emit(dims)


def prompt_nut(f, c, d):
    af = get(f, "width") or get(f, "square_width")
    th = get(f, "thickness") or get(f, "square_thickness")
    bore = get(f, "size")
    kind = "hex nut"
    if "hammer" in c: kind = "hammer nut for aluminium extrusion"
    elif "sliding_t" in c or "sliding_ball_t" in c: kind = "sliding T-nut for aluminium extrusion"
    elif "weld" in c: kind = "weld nut"
    elif "wingnut" in c: kind = "wing nut"
    elif "thin" in c or c.endswith("_thin_nut"): kind = "thin hex nut"
    elif "half" in c: kind = "half-height hex nut"
    dims = []
    if bore: dims.append(f"{bore} mm thread bore")
    if af:   dims.append(f"{af} mm across flats")
    if th:   dims.append(f"{th} mm thick")
    return f"A {kind}" + _emit(dims)


def prompt_washer(f, c, d):
    bore = get(f, "size")
    od = get(f, "diameter")
    th = get(f, "thickness")
    kind = "flat washer"
    if "penny" in c: kind = "penny washer (large-OD flat washer)"
    elif "rubber" in c: kind = "rubber washer"
    elif "star" in c: kind = "star (serrated) washer"
    elif "spring" in c: kind = "split-spring washer"
    dims = []
    if bore: dims.append(f"{bore} mm bore")
    if od:   dims.append(f"{od} mm outer diameter")
    if th:   dims.append(f"{th} mm thick")
    return f"A {kind}" + _emit(dims)


def prompt_extrusion(f, c, d):
    w = num(f, "width"); h = num(f, "height")
    # NopSCADlib convention: if the *_wd fields are negative the feature is
    # round with that diameter; if positive it is square with that side.
    def _hole_desc(k_wd: str, round_label: str, square_label: str) -> str | None:
        raw = f.get(k_wd)
        v = _eval_scad_scalar(raw) if raw is not None else None
        if v in (None, "", "0"):
            return None
        try:
            fv = float(v)
        except ValueError:
            return None
        mag = f"{abs(fv):g}"
        return f"{mag} mm {round_label}" if fv < 0 else f"{mag} mm {square_label}"

    center = _hole_desc("center_hole_wd",
                        "round central through-bore",
                        "square central through-bore")
    corner = _hole_desc("corner_hole_wd",
                        "round corner screw-hole",
                        "square corner screw-hole")
    inner_sq = _hole_desc("center_square_wd",
                          "round inner chamber diameter",
                          "square inner chamber size")
    t_slot_w = num(f, "channel_width")
    t_slot_i = num(f, "channel_width_internal")
    tab_t = num(f, "tab_thickness")
    spar_t = num(f, "spar_thickness")
    fillet = num(f, "fillet")
    dims = []
    if w and h:   dims.append(f"{w} mm by {h} mm cross-section")
    if center:    dims.append(center)
    if inner_sq:  dims.append(inner_sq)
    if corner:    dims.append(corner)
    if t_slot_w:  dims.append(f"{t_slot_w} mm T-slot opening width")
    if t_slot_i:  dims.append(f"{t_slot_i} mm internal slot channel width")
    if tab_t:     dims.append(f"{tab_t} mm T-slot lip thickness")
    if spar_t:    dims.append(f"{spar_t} mm internal spar thickness")
    if fillet:    dims.append(f"{fillet} mm corner fillet")
    return "A T-slot aluminium extrusion profile" + _emit(dims)


def prompt_pulley(f, c, d):
    teeth = get(f, "teeth"); od = get(f, "od"); w = get(f, "width")
    bore = get(f, "bore")
    hd = get(f, "hub_dia") or get(f, "hub_diameter")
    hl = get(f, "hub_length")
    fld = get(f, "flange_dia") or get(f, "flange_diameter")
    flt = get(f, "flange_thickness")
    kind = "timing-belt pulley"
    if "GT2" in c: kind = "GT2 timing-belt pulley"
    elif "MXL" in c: kind = "MXL timing-belt pulley"
    elif "HTD" in c: kind = "HTD timing-belt pulley"
    elif "T5" in c or "_T_" in c: kind = "T5 timing-belt pulley"
    dims = []
    if teeth: dims.append(f"{teeth} teeth")
    if od:    dims.append(f"{od} mm outside diameter")
    if w:     dims.append(f"{w} mm belt width")
    if bore:  dims.append(f"{bore} mm bore")
    if hd:    dims.append(f"{hd} mm hub diameter")
    if hl:    dims.append(f"{hl} mm hub length")
    if fld:   dims.append(f"{fld} mm flange diameter")
    if flt:   dims.append(f"{flt} mm flange thickness")
    return f"A {kind}" + _emit(dims)


def prompt_pcb(f, c, d):
    L = get(f, "length"); W = get(f, "width"); T = get(f, "thickness")
    r = get(f, "radius")
    hd = get(f, "hole_d") or get(f, "hole_dia")
    dims = []
    if L and W: dims.append(f"{L} mm x {W} mm")
    if T:       dims.append(f"{T} mm thick")
    if r:       dims.append(f"{r} mm corner radius")
    if hd:      dims.append(f"{hd} mm mounting-hole diameter")
    return "A printed-circuit board" + _emit(dims)


_MATERIAL_MAP_SHEET = {
    "AL": "aluminium",
    "CF": "carbon-fibre",
    "MDF": "MDF fibreboard",
    "PMMA": "acrylic (PMMA)",
    "PET": "PET",
    "PC": "polycarbonate",
    "PS": "polystyrene",
    "HDPE": "HDPE",
    "FR": "FR4 fibreglass",
    "DIBOND": "aluminium-composite panel",
    "STEEL": "mild steel",
    "SPRING": "spring steel",
    "SILICONE": "silicone rubber",
    "FOAM": "closed-cell foam",
    "FOILTAPE": "aluminium foil tape",
    "CARDBOARD": "corrugated cardboard",
    "SELLOTAPE": "clear adhesive tape",
}


def prompt_sheet(f, c, d):
    th = get(f, "thickness")
    if not th:
        m = re.search(r"(\d+(?:p\d+)?)$", c)
        th = m.group(1).replace("p", ".") if m else None
    stem = re.sub(r"\d+(?:p\d+)?$", "", c.rstrip("_"))
    material = None
    for k in sorted(_MATERIAL_MAP_SHEET, key=len, reverse=True):
        if stem.upper().startswith(k):
            material = _MATERIAL_MAP_SHEET[k]
            break
    if material is None:
        human = (get_raw(f, "_field_1") or "").strip().strip('"')
        if human:
            human = re.sub(r"^[Ss]heet\s+", "", human)
            # Try to avoid brand names by replacing obvious ones.
            human = re.sub(r"(?i)\bsellotape\b", "clear adhesive", human)
            material = human
        else:
            material = "sheet material"
    return f"A {th} mm thick sheet of {material}." if th else f"A sheet of {material}."


def prompt_linear_bearing(f, c, d):
    length = get(f, "length")
    od = get(f, "dia")
    bore = get(f, "rod_dia")
    open_type = c.endswith("OP") or "OP" in c[-3:]
    long_type = c.endswith("LUU") or "L" in c[-3:]
    kind_bits = []
    if long_type: kind_bits.append("long")
    if open_type: kind_bits.append("open-type")
    kind = "linear ball bearing" if not kind_bits else " ".join(kind_bits) + " linear ball bearing"
    dims = []
    if bore:   dims.append(f"{bore} mm bore")
    if od:     dims.append(f"{od} mm outer diameter")
    if length: dims.append(f"{length} mm length")
    return f"A {kind}" + _emit(dims)


def prompt_insert(f, c, d):
    length = get(f, "length") or get(f, "depth") or get(f, "height")
    od = get(f, "outer_d") or get(f, "diameter") or get(f, "OD") or get(f, "ring_d")
    # Accessor occasionally stores the thread nominal in field 'bore' or the size name.
    m = re.search(r"M(\d+(?:p\d+)?)", c)
    thr = m.group(1).replace("p", ".") if m else None
    dims = []
    if thr:    dims.append(f"{thr} mm thread bore")
    if od:     dims.append(f"{od} mm outer diameter")
    if length: dims.append(f"{length} mm length")
    return "A heat-set brass threaded insert" + _emit(dims)


def prompt_stepper(f, c, d):
    body_L = None
    for k in ("body_length", "length", "L"):
        if k in f:
            body_L = fmt_num(f[k]); break
    return "A stepper motor" + (f": {body_L} mm body length." if body_L else ".")


_TUBING_MATERIAL = {
    "PTFE": "PTFE (Teflon)",
    "STFE": "STFE fluoropolymer",
    "PVC": "PVC",
    "NEOP": "neoprene rubber",
    "HSHRNK": "heat-shrink",
    "PF": "polyethylene",
    "CARBONFIBER": "carbon-fibre",
    "CARBON": "carbon-fibre",
    "SILICONE": "silicone rubber",
    "NYLON": "nylon",
    "BRASS": "brass",
}


def prompt_tubing(f, c, d):
    od = get(f, "od") or get(f, "diameter")
    idv = get(f, "id") or get(f, "inner_diameter")
    mat = "tubing"
    upper = c.upper()
    for k, v in _TUBING_MATERIAL.items():
        if upper.startswith(k):
            mat = f"{v} tubing"; break
    dims = []
    if od:  dims.append(f"{od} mm outer diameter")
    if idv: dims.append(f"{idv} mm inner diameter")
    return f"A length of {mat}" + _emit(dims)


def prompt_ht_pipe(f, c, d):
    m = re.match(r"HT_(\d+(?:p\d+)?)_pipe_(\d+)", c)
    if m:
        dia = m.group(1).replace("p", "."); length = m.group(2)
        return f"A length of HT drainage pipe: {dia} mm nominal diameter, {length} mm long."
    m = re.match(r"HT_(\d+(?:p\d+)?)_cap", c)
    if m:
        dia = m.group(1).replace("p", ".")
        return f"An HT drainage-pipe end cap: {dia} mm nominal diameter."
    m = re.match(r"HT_(\d+)_(\d+)_tpipe", c)
    if m:
        return f"An HT drainage T-pipe fitting: {m.group(1)} mm main bore, {m.group(2)} mm branch bore."
    if c.endswith("_tpipe"):
        return "An HT drainage T-pipe fitting."
    return "An HT drainage-pipe component."


def prompt_led(f, c, d):
    m = re.match(r"LED(\d+)", c)
    if m:
        return f"A through-hole LED: {m.group(1)} mm lens diameter."
    m = re.match(r"(\d+)x(\d+)", c)
    if m:
        return f"A rectangular through-hole LED: {m.group(1)} mm x {m.group(2)} mm body."
    return "A through-hole LED."


_SMD_FAMILIES = {
    "RES": "SMD chip resistor",
    "CAP": "SMD ceramic chip capacitor",
    "LED": "SMD chip LED",
    "IND": "SMD chip inductor",
    "TANT": "SMD tantalum capacitor",
    "SOIC": "SOIC surface-mount IC package",
    "SOT": "SOT surface-mount IC package",
    "QFP": "QFP surface-mount IC package",
    "DO": "surface-mount diode",
    "TC": "SMD trimmer capacitor",
    "CDRH": "shielded SMD power inductor",
    "OMT": "SMD oscillator module",
    "TSOT": "TSOT surface-mount IC package",
    "L": "SMD chip inductor",
    "U_FL": "U.FL miniature RF coaxial SMD connector",
}


def prompt_smd(f, c, d):
    # Try to recover a body-size code suffix (e.g. RES0402, CAP0805, SOIC14).
    m = re.match(r"([A-Z_]+)(\d+)", c)
    desc = "SMD component"
    size_note = None
    if m:
        key = m.group(1).upper().rstrip("_")
        desc = _SMD_FAMILIES.get(key, desc)
        size = m.group(2)
        # Two-letter/EIA size codes come in pairs like 0402 (= 1.0 mm x 0.5 mm).
        if len(size) == 4 and key in {"RES", "CAP", "LED", "IND", "TANT"}:
            pairs = {
                "0201": "0.6 mm x 0.3 mm",
                "0402": "1.0 mm x 0.5 mm",
                "0603": "1.6 mm x 0.8 mm",
                "0805": "2.0 mm x 1.25 mm",
                "1206": "3.2 mm x 1.6 mm",
                "1210": "3.2 mm x 2.5 mm",
                "1812": "4.5 mm x 3.2 mm",
                "2010": "5.0 mm x 2.5 mm",
                "2512": "6.5 mm x 3.2 mm",
            }
            size_note = pairs.get(size)
        elif key in {"SOIC", "QFP", "TSOT"}:
            size_note = f"{size}-pin body"
        elif key == "SOT":
            size_note = f"SOT-{size} outline"
    return f"A {desc}" + (f": {size_note}." if size_note else ".")


def prompt_rail(f, c, d):
    m = re.match(r"(MGN|HGH|SSR)(\d+)", c)
    length = get(f, "length")
    dims = []
    if m:
        rail_size = m.group(2)
        dims.append(f"{rail_size} mm rail size")
    if length:
        dims.append(f"{length} mm length")
    fam = "profile linear rail"
    if m:
        fam = {
            "MGN": "miniature profile linear rail",
            "HGH": "heavy-duty profile linear rail",
            "SSR": "profile linear guide rail",
        }.get(m.group(1), fam)
    return f"A {fam}" + _emit(dims)


def prompt_radial(f, c, d):
    for k in ("xtal_size", "length", "body_length", "body_size"):
        vec = _parse_vec(f.get(k, ""))
        if vec and len(vec) >= 2 and vec[0] is not None and vec[1] is not None:
            return (f"A through-hole radial electronic component: "
                    f"{vec[0]:g} mm x {vec[1]:g} mm body.")
    return "A through-hole radial electronic component."


def prompt_axial(f, c, d):
    length = get(f, "res_length") or get(f, "length") or get(f, "body_length")
    vec = _parse_vec(f.get("res_diameter", ""))
    if vec and length and vec and vec[0] is not None:
        return (f"A through-hole axial electronic component: "
                f"{vec[0]:g} mm body diameter, {length} mm body length.")
    if length:
        return f"A through-hole axial electronic component: {length} mm body length."
    return "A through-hole axial electronic component."


def prompt_ball_batt(f, c, d):
    L = get(f, "length"); D = get(f, "diameter")
    name = c.upper()
    if re.match(r"LI\d+|L\d+|S\d+R\d+", name):
        kind = "Li-ion cylindrical rechargeable cell"
    elif name.replace("CELL", "") in {"AA", "AAA", "C", "D", "A23"}:
        kind = "cylindrical dry-cell battery"
    elif "LUMINTOP" in name:
        kind = "Li-ion cylindrical cell with built-in USB charging port"
    else:
        kind = "cylindrical battery cell"
    dims = []
    if D: dims.append(f"{D} mm diameter")
    if L: dims.append(f"{L} mm length")
    return f"A {kind}" + _emit(dims)


def prompt_bldc(f, c, d):
    dia = num(f, "BLDC_diameter", "diameter")
    h = num(f, "BLDC_height", "height")
    shaft_d = num(f, "BLDC_shaft_diameter", "shaft_diameter")
    shaft_l = num(f, "BLDC_shaft_length", "shaft_length")
    base_d = num(f, "BLDC_base_diameter", "base_diameter")
    bell_d = num(f, "BLDC_bell_diameter", "bell_diameter")
    if not (dia and h):
        m = re.match(r"BLDC(\d{2})(\d{2})", c)
        if m:
            dia = dia or str(int(m.group(1)))
            h = h or str(int(m.group(2)))
    dims = []
    if dia:     dims.append(f"{dia} mm body diameter")
    if h:       dims.append(f"{h} mm body height")
    if bell_d and bell_d != dia: dims.append(f"{bell_d} mm bell diameter")
    if base_d:  dims.append(f"{base_d} mm base plate diameter")
    if shaft_d: dims.append(f"{shaft_d} mm shaft diameter")
    if shaft_l: dims.append(f"{shaft_l} mm shaft length")
    return "A brushless DC outrunner motor" + _emit(dims)


def prompt_stepper_motor(f, c, d):
    face = num(f, "NEMA_width", "width")
    body_L = num(f, "NEMA_length", "body_length", "length")
    shaft_d = num(f, "NEMA_shaft_dia", "shaft_diameter")
    shaft_l = num(f, "NEMA_shaft_length", "shaft_length")
    boss_r = num(f, "NEMA_boss_radius")
    boss_h = num(f, "NEMA_boss_height")
    pitch = num(f, "NEMA_hole_pitch", "hole_pitch")
    thread_d = num(f, "NEMA_thread_d")
    dims = []
    if face:    dims.append(f"{face} mm square mounting face")
    if body_L:  dims.append(f"{body_L} mm body length")
    if boss_r and boss_h:
        dims.append(f"{boss_r} mm radius boss, {boss_h} mm tall")
    if shaft_d: dims.append(f"{shaft_d} mm shaft diameter")
    if shaft_l: dims.append(f"{shaft_l} mm shaft length above the face")
    if pitch:   dims.append(f"{pitch} mm mounting-hole pitch")
    if thread_d:dims.append(f"{thread_d} mm mounting-hole diameter")
    return "A hybrid stepper motor" + _emit(dims)


def prompt_camera(f, c, d):
    # Camera constants reference an external PCB table for outline; emit
    # whatever scalar fields we have at the camera level.
    dims = []
    fov = _parse_vec(f.get("fov", ""))
    if fov and len(fov) == 2 and fov[0] is not None and fov[1] is not None:
        dims.append(f"{fov[0]:g}\u00b0 x {fov[1]:g}\u00b0 field of view")
    conn = _parse_vec(f.get("connector_size", ""))
    if conn and len(conn) == 3 and all(x is not None for x in conn):
        dims.append(f"{conn[0]:g} mm x {conn[1]:g} mm x {conn[2]:g} mm ribbon connector")
    return "A camera module" + _emit(dims)


def prompt_display(f, c, d):
    W = get(f, "width") or get(f, "length")
    H = get(f, "height") or get(f, "depth")
    T = get(f, "thickness")
    dims = []
    if W and H: dims.append(f"{W} mm x {H} mm front bezel")
    if T:       dims.append(f"{T} mm bezel thickness")
    return "A PCB-based display module" + _emit(dims)


def prompt_panel_meter(f, c, d):
    body = _parse_vec(f.get("size", ""))
    bezel = _parse_vec(f.get("bezel", ""))
    ap = _parse_vec(f.get("aperture", ""))
    dims = []
    if body and len(body) >= 3 and all(x is not None for x in body[:3]):
        dims.append(f"{body[0]:g} mm x {body[1]:g} mm body, {body[2]:g} mm depth")
    if bezel and len(bezel) >= 3 and all(x is not None for x in bezel[:3]):
        dims.append(f"{bezel[0]:g} mm x {bezel[1]:g} mm bezel")
    if ap and len(ap) >= 2 and all(x is not None for x in ap[:2]):
        dims.append(f"{ap[0]:g} mm x {ap[1]:g} mm display aperture")
    return "A panel-mount electrical meter" + _emit(dims)


def prompt_mains_socket(f, c, d):
    w = get(f, "socket_width") or get(f, "width")
    d2 = get(f, "socket_depth") or get(f, "depth")
    h = get(f, "socket_height") or get(f, "height")
    t = get(f, "socket_t") or get(f, "thickness")
    pitch = get(f, "socket_pitch") or get(f, "pitch")
    dims = []
    if w and d2: dims.append(f"{w} mm x {d2} mm face")
    if h:        dims.append(f"{h} mm height")
    if t:        dims.append(f"{t} mm wall thickness")
    if pitch:    dims.append(f"{pitch} mm screw-hole pitch")
    return "A flush-mount mains-power wall socket" + _emit(dims)


def prompt_iec(f, c, d):
    bw = get(f, "body_w") or get(f, "width")
    bh = get(f, "body_h") or get(f, "height")
    fw = get(f, "flange_w")
    fh = get(f, "flange_h")
    ft = get(f, "flange_t")
    depth = get(f, "depth")
    pitch = get(f, "pitch")
    male = (f.get("male", "").lower() == "true")
    kind = "IEC mains-power outlet" if male else "IEC mains-power inlet"
    dims = []
    if bw and bh:  dims.append(f"{bw} mm x {bh} mm body")
    if fw and fh:  dims.append(f"{fw} mm x {fh} mm flange")
    if ft:         dims.append(f"{ft} mm flange thickness")
    if depth:      dims.append(f"{depth} mm depth")
    if pitch:      dims.append(f"{pitch} mm mounting-screw pitch")
    return f"An {kind}" + _emit(dims)


def prompt_magnet(f, c, d):
    od = num(f, "od")
    idv = num(f, "id")
    h = num(f, "h", "height")
    r = num(f, "r", "radius")
    # Fall back to code pattern when the library entry uses inch() helpers
    # that we still can't resolve.
    if not (od and h):
        m = re.match(r"MAG(\d+)x(\d+)(?:x(\d+(?:p\d+)?))?", c)
        if m:
            a = m.group(1); b = m.group(2); c3 = m.group(3)
            if c3:
                return f"A rectangular neodymium magnet: {a} mm x {b} mm x {c3.replace('p', '.')} mm."
            return f"A cylindrical neodymium magnet: {a} mm diameter, {b} mm height."
        m = re.match(r"MAGRE(\d+)x(\d+(?:p\d+)?)", c)
        if m:
            return (f"A ring neodymium magnet: {m.group(1)} mm outer diameter, "
                    f"{m.group(2).replace('p', '.')} mm height.")
    dims = []
    ring = idv and idv != "0"
    if od:   dims.append(f"{od} mm outer diameter")
    if ring: dims.append(f"{idv} mm inner diameter")
    if h:    dims.append(f"{h} mm height")
    if r and r != "0": dims.append(f"{r} mm corner radius")
    head = "A ring neodymium magnet" if ring else "A cylindrical neodymium magnet"
    return head + _emit(dims)


def prompt_d_connector(f, c, d):
    ways = get(f, "ways")
    flange_L = get(f, "flange_length")
    flange_W = get(f, "flange_width")
    flange_T = get(f, "flange_thickness")
    pitch = get(f, "hole_pitch")
    dims = []
    if ways:                dims.append(f"{ways} pins")
    if flange_L and flange_W: dims.append(f"{flange_L} mm x {flange_W} mm flange")
    if flange_T:            dims.append(f"{flange_T} mm flange thickness")
    if pitch:               dims.append(f"{pitch} mm mounting-hole pitch")
    if not dims:
        m = re.match(r"DCONN(\d+)", c)
        if m:
            dims.append(f"{m.group(1)} pins")
    return "A D-subminiature connector" + _emit(dims)


def prompt_blower(f, c, d):
    L = get(f, "length"); W = get(f, "width"); D = get(f, "depth")
    bore = get(f, "bore"); exit_ = get(f, "exit"); hub = get(f, "hub")
    dims = []
    if L and W: dims.append(f"{L} mm x {W} mm envelope")
    if D:       dims.append(f"{D} mm depth")
    if bore:    dims.append(f"{bore} mm intake diameter")
    if exit_:   dims.append(f"{exit_} mm exit port width")
    if hub:     dims.append(f"{hub} mm rotor hub diameter")
    return "A radial blower fan" + _emit(dims)


def prompt_transformer(f, c, d):
    W = get(f, "width"); D = get(f, "depth"); H = get(f, "height")
    fw = get(f, "foot_width"); fd = get(f, "foot_depth"); ft = get(f, "foot_thickness")
    xp = get(f, "x_pitch"); yp = get(f, "y_pitch")
    lam_d = get(f, "lamination_depth"); lam_h = get(f, "lamination_height")
    dims = []
    if W and D and H: dims.append(f"{W} mm x {D} mm x {H} mm bounding envelope")
    if fw and fd:     dims.append(f"{fw} mm x {fd} mm foot")
    if ft:            dims.append(f"{ft} mm foot thickness")
    if xp and yp:     dims.append(f"{xp} mm x {yp} mm screw-hole pattern")
    if lam_d and lam_h: dims.append(f"{lam_d} mm x {lam_h} mm lamination stack")
    return "A laminated-core mains isolation transformer" + _emit(dims)


def prompt_gear_motor(f, c, d):
    box = _parse_vec(f.get("box", "")) or []
    motor = _parse_vec(f.get("motor", "")) or []
    shaft = _parse_vec(f.get("shaft", "")) or []
    dims = []
    if len(box) >= 3 and box[0] is not None and box[2] is not None:
        if box[1] in (None, 0, 0.0):
            dims.append(f"{box[0]:g} mm diameter round gearbox, {box[2]:g} mm tall")
        elif box[1] is not None:
            dims.append(f"{box[0]:g} mm x {box[1]:g} mm gearbox, {box[2]:g} mm tall")
        else:
            dims.append(f"{box[0]:g} mm gearbox, {box[2]:g} mm tall")
    # motor[0] is a position sub-vector in NopSCADlib; motor[1]=dia, [2]=height.
    if len(motor) >= 3 and motor[1] is not None and motor[2] is not None:
        dims.append(f"{motor[1]:g} mm motor diameter, {motor[2]:g} mm motor length")
    if len(shaft) >= 3 and shaft[0] is not None and shaft[2] is not None:
        dims.append(f"{shaft[0]:g} mm shaft diameter, {shaft[2]:g} mm shaft length")
    return "A geared DC motor with integrated gearbox" + _emit(dims)


def prompt_servo_motor(f, c, d):
    body_L = num(f, "boss_size", "length")
    face = None
    m = re.search(r"(\d+)ST", c)
    if m:
        face = int(m.group(1))
    vec = _parse_vec(f.get("thickness", ""))
    cap_d = cap_h = None
    if vec and len(vec) == 3 and all(x is not None for x in vec):
        cap_d = vec[0]
        cap_h = vec[2] if vec[2] > vec[1] else vec[1]
    dims = []
    if face:   dims.append(f"{face} mm square flange")
    if body_L: dims.append(f"{body_L} mm body length")
    if cap_d and cap_h:
        dims.append(f"{cap_d:g} mm diameter encoder cover, {cap_h:g} mm tall")
    return "An industrial AC servo motor" + _emit(dims)


def prompt_hot_end(f, c, d):
    tl = get(f, "end_total_length") or get(f, "total_length")
    ins = get(f, "end_inset") or get(f, "inset")
    ins_d = get(f, "end_insulator_diameter") or get(f, "insulator_diameter")
    ins_l = get(f, "end_insulator_length") or get(f, "insulator_length")
    groove_d = get(f, "end_groove_dia") or get(f, "groove_dia")
    groove_l = get(f, "end_groove") or get(f, "groove")
    dims = []
    if tl:     dims.append(f"{tl} mm overall length")
    if ins:    dims.append(f"{ins} mm mount inset")
    if ins_d:  dims.append(f"{ins_d} mm insulator diameter")
    if ins_l:  dims.append(f"{ins_l} mm insulator length")
    if groove_d and groove_l: dims.append(f"{groove_d} mm mounting groove over {groove_l} mm")
    return "A 3D-printer hot-end assembly" + _emit(dims)


def prompt_pillar(f, c, d):
    thread = num(f, "thread")
    height = num(f, "height")
    od = num(f, "od")
    idv = num(f, "id")

    def _end(raw: str | None, side: str) -> str | None:
        v = _eval_scad_scalar(raw) if raw is not None else None
        if v in (None, "", "0"):
            return None
        try:
            fv = float(v)
        except ValueError:
            return None
        mag = f"{abs(fv):g}"
        return (f"{mag} mm {side} male stud" if fv > 0 else f"{mag} mm {side} threaded recess")

    top = _end(f.get("top_thread"), "top")
    bot = _end(f.get("bot_thread"), "bottom")
    kind = "hex brass standoff pillar"
    lower = c.lower()
    if "female_pillar" in lower: kind = "female-female brass standoff pillar"
    elif "pillar" in lower: kind = "threaded brass standoff pillar"
    if "nurled" in (get_raw(f, "name") or "").lower() or "knurled" in lower:
        kind = "knurled brass standoff pillar"
    dims = []
    if thread: dims.append(f"{thread} mm thread size")
    if height: dims.append(f"{height} mm body length")
    if od:     dims.append(f"{od} mm body outer diameter")
    if idv and idv != od: dims.append(f"{idv} mm body inner diameter")
    if top: dims.append(top)
    if bot: dims.append(bot)
    return f"A {kind}" + _emit(dims)


def prompt_ring_terminal(f, c, d):
    od = get(f, "od"); idv = get(f, "id")
    L = get(f, "length"); W = get(f, "width")
    hole = get(f, "hole"); t = get(f, "thickness")
    dims = []
    if od:    dims.append(f"{od} mm ring outer diameter")
    if idv:   dims.append(f"{idv} mm ring bore")
    if L:     dims.append(f"{L} mm total length")
    if W:     dims.append(f"{W} mm tail width")
    if hole:  dims.append(f"{hole} mm wire-entry hole")
    if t:     dims.append(f"{t} mm metal thickness")
    return "A crimp ring terminal" + _emit(dims)


def prompt_rod_end(f, c, d):
    bore = get(f, "end_bearing_bore") or get(f, "bearing_bore")
    od = get(f, "end_bearing_od") or get(f, "bearing_od")
    width = get(f, "end_bearing_width") or get(f, "bearing_width")
    thr_l = get(f, "end_thread_length")
    overall = get(f, "end_overall_length")
    dims = []
    if bore:    dims.append(f"{bore} mm eye bore")
    if od:      dims.append(f"{od} mm eye outer diameter")
    if width:   dims.append(f"{width} mm eye width")
    if thr_l:   dims.append(f"{thr_l} mm thread length")
    if overall: dims.append(f"{overall} mm overall length")
    return "A rod-end spherical bearing" + _emit(dims)


def prompt_shaft_coupling(f, c, d):
    length = get(f, "length")
    od = get(f, "diameter")
    d1 = get(f, "diameter1"); d2 = get(f, "diameter2")
    flex = (f.get("flexible", "").lower() == "true")
    kind = "flexible shaft coupling" if flex else "rigid shaft coupling"
    dims = []
    if length: dims.append(f"{length} mm length")
    if od:     dims.append(f"{od} mm outer diameter")
    if d1 and d2 and d1 != d2:
        dims.append(f"{d1} mm input shaft bore, {d2} mm output shaft bore")
    elif d1:
        dims.append(f"{d1} mm shaft bore")
    return f"A {kind}" + _emit(dims)


def prompt_sk_bracket(f, c, d):
    rod = num(f, "diameter")
    vec = _parse_vec(f.get("size", ""))
    base_h = num(f, "base_height")
    sep = num(f, "screw_separation")
    dims = []
    if rod: dims.append(f"{rod} mm rod bore")
    if vec and len(vec) >= 3 and all(x is not None for x in vec[:3]):
        dims.append(f"{vec[0]:g} mm wide x {vec[1]:g} mm deep, {vec[2]:g} mm tall")
    if base_h: dims.append(f"{base_h} mm base height")
    if sep:    dims.append(f"{sep} mm mounting-screw pitch")
    return "A shaft-support bracket" + _emit(dims)


def prompt_sbr_rail(f, c, d):
    rod_d = get(f, "diameter")
    ch = get(f, "center_height")
    bw = get(f, "base_width")
    dims = []
    if rod_d: dims.append(f"{rod_d} mm round-rail diameter")
    if ch:    dims.append(f"{ch} mm rail-centre height")
    if bw:    dims.append(f"{bw} mm base width")
    return "A supported round-rail linear guide" + _emit(dims)


def prompt_bearing_block(f, c, d):
    bore = get(f, "_field_1") or get(f, "bore")
    hole_off = get(f, "hole_offset")
    center_h = get(f, "block_center_height")
    side_h = get(f, "block_side_height")
    sep_x = get(f, "screw_separation_x")
    sep_z = get(f, "screw_separation_z")
    dims = []
    if bore:     dims.append(f"{bore} mm shaft bore")
    if hole_off: dims.append(f"{hole_off} mm centre-line offset")
    if center_h: dims.append(f"{center_h} mm height to shaft centre")
    if side_h:   dims.append(f"{side_h} mm base flange height")
    if sep_x and sep_z: dims.append(f"{sep_x} mm x {sep_z} mm mounting-screw pattern")
    return "A linear-shaft bearing block" + _emit(dims)


def prompt_pillow_block(f, c, d):
    bore = get(f, "diameter")
    hole_off = get(f, "hole_offset")
    base_h = get(f, "base_height")
    sep = get(f, "screw_separation")
    dims = []
    if bore:     dims.append(f"{bore} mm shaft bore")
    if hole_off: dims.append(f"{hole_off} mm centre-line offset")
    if base_h:   dims.append(f"{base_h} mm base height")
    if sep:      dims.append(f"{sep} mm mounting-bolt pitch")
    return "A pillow-block ball-bearing housing" + _emit(dims)


def prompt_light_strip(f, c, d):
    L = get(f, "strip_length") or get(f, "length")
    leds = get(f, "strip_leds") or get(f, "leds")
    grouped = get(f, "strip_grouped")
    W = get(f, "strip_width")
    D = get(f, "strip_depth")
    ap = get(f, "strip_aperture")
    t = get(f, "strip_thickness")
    pcb_t = get(f, "strip_pcb_thickness")
    dims = []
    if L:       dims.append(f"{L} mm uncut length")
    if leds:    dims.append(f"{leds} LEDs" + (f" ({grouped} per segment)" if grouped else ""))
    if W:       dims.append(f"{W} mm outer width")
    if D:       dims.append(f"{D} mm outer depth")
    if ap:      dims.append(f"{ap} mm aperture")
    if t:       dims.append(f"{t} mm aluminium channel thickness")
    if pcb_t:   dims.append(f"{pcb_t} mm PCB thickness")
    return "A rigid aluminium-channel LED light strip" + _emit(dims)


def prompt_psu(f, c, d):
    # The psu schema is largely reference-heavy; we try to extract any
    # integer tokens from the code that encode wattage/voltage.
    m = re.match(r"S_(\d+)_(\d+)", c)
    if m:
        return f"An enclosed switch-mode power supply: {m.group(1)} W output power, {m.group(2)} V output."
    return "An enclosed switch-mode power supply."


def prompt_ssr(f, c, d):
    m = re.match(r"SSR(\d+)DA", c)
    if m:
        return f"A DC-controlled AC-switching solid-state relay: {m.group(1)} A load current."
    return "A solid-state relay."


def prompt_potentiometer(f, c, d):
    body = _parse_vec(f.get("body", ""))
    thread_d = num(f, "thread_d")
    thread_h = num(f, "thread_h")
    shaft = _parse_vec(f.get("shaft", ""))
    dims = []
    if body and len(body) >= 3 and all(x is not None for x in body[:3]):
        dims.append(f"{body[0]:g} mm x {body[1]:g} mm x {body[2]:g} mm body")
    if thread_d and thread_h:
        dims.append(f"{thread_d} mm bushing thread, {thread_h} mm long")
    if shaft and len(shaft) >= 3 and shaft[0] is not None and shaft[2] is not None:
        dims.append(f"{shaft[0]:g} mm shaft diameter, {shaft[2]:g} mm shaft length")
    return "A panel-mount rotary potentiometer / encoder" + _emit(dims)


def prompt_leadnut(f, c, d):
    bore = get(f, "bore")
    od = get(f, "od")
    height = get(f, "height")
    flange_d = get(f, "flange_dia")
    flange_t = get(f, "flange_t")
    dims = []
    if bore:     dims.append(f"{bore} mm lead-screw bore")
    if od:       dims.append(f"{od} mm shank outer diameter")
    if height:   dims.append(f"{height} mm total height")
    if flange_d and flange_d != "-1": dims.append(f"{flange_d} mm flange diameter")
    if flange_t: dims.append(f"{flange_t} mm flange thickness")
    return "A lead-screw nut" + _emit(dims)


def prompt_photo_interrupter(f, c, d):
    bw = get(f, "base_width")
    bl = get(f, "base_length")
    bh = get(f, "base_height")
    gh = get(f, "gap_height")
    gw = get(f, "gap_width")
    hole = get(f, "hole_diameter")
    dims = []
    if bl and bw and bh: dims.append(f"{bl} mm x {bw} mm x {bh} mm base")
    if gw and gh:        dims.append(f"{gw} mm x {gh} mm optical gap")
    if hole:             dims.append(f"{hole} mm mounting-hole diameter")
    return "An optical slotted photo-interrupter" + _emit(dims)


def prompt_toggle(f, c, d):
    w = get(f, "width"); h = get(f, "height"); d2 = get(f, "depth")
    od = get(f, "od"); idv = get(f, "id")
    thread = get(f, "thread")
    paddle = get(f, "paddle_l")
    dims = []
    if w and h and d2: dims.append(f"{w} mm x {h} mm x {d2} mm body")
    if od and idv:     dims.append(f"{od} mm bushing OD over {idv} mm bore")
    if thread:         dims.append(f"{thread} mm thread length")
    if paddle:         dims.append(f"{paddle} mm paddle length")
    return "A panel-mount toggle switch" + _emit(dims)


def prompt_swiss_clip(f, c, d):
    L = get(f, "length"); H = get(f, "height"); W = get(f, "width")
    t = get(f, "thickness"); mg = get(f, "max_gap")
    dims = []
    if L and H and W: dims.append(f"{L} mm x {H} mm x {W} mm envelope")
    if t:             dims.append(f"{t} mm sheet-metal thickness")
    if mg:            dims.append(f"{mg} mm maximum opening")
    return "A Swiss-style spring mounting clip" + _emit(dims)


def prompt_component(f, c, d):
    # This family is a catch-all for random through-hole / thermistor-style
    # bodies. We extract whatever scalar dimensions we can find.
    W = get(f, "width"); T = get(f, "thickness")
    BL = get(f, "body_length")
    dims = []
    if W and T: dims.append(f"{W} mm wide x {T} mm thick")
    if BL:      dims.append(f"{BL} mm body length")
    return "A through-hole electronic component package" + _emit(dims)


def prompt_variac(f, c, d):
    dia = get(f, "diameter")
    h = get(f, "height")
    bulge_d = get(f, "bulge_dia")
    bulge_w = get(f, "bulge_width")
    shaft_d = get(f, "shaft_dia")
    shaft_l = get(f, "shaft_length")
    dial = get(f, "dial_dia")
    dims = []
    if dia:     dims.append(f"{dia} mm body diameter")
    if h:       dims.append(f"{h} mm body height")
    if bulge_d and bulge_w: dims.append(f"{bulge_d} mm x {bulge_w} mm rear bulge")
    if shaft_d and shaft_l: dims.append(f"{shaft_d} mm shaft diameter, {shaft_l} mm shaft length")
    if dial:    dims.append(f"{dial} mm dial diameter")
    return "A rotary variable autotransformer (variac)" + _emit(dims)


def prompt_box_section(f, c, d):
    size = _parse_vec(f.get("section_size") or f.get("size", ""))
    th = num(f, "section_thickness", "thickness")
    fillet = num(f, "section_fillet", "fillet")
    colour2 = get_raw(f, "section_colour2", "colour2")
    woven = colour2 not in (None, "", "undef")
    material = "metal"
    upper = c.upper()
    if upper.startswith("AL"):
        material = "aluminium"
    elif upper.startswith("CF"):
        material = "woven carbon-fibre" if woven else "carbon-fibre"
    elif upper.startswith("STEEL") or upper.startswith("ST"):
        material = "steel"
    dims = []
    if size and len(size) >= 2 and size[0] is not None and size[1] is not None:
        dims.append(f"{size[0]:g} mm x {size[1]:g} mm cross-section")
    else:
        m = re.match(r"[A-Z]+(\d+)x(\d+)x", upper)
        if m:
            dims.append(f"{m.group(1)} mm x {m.group(2)} mm cross-section")
    if th:
        dims.append(f"{th} mm wall thickness")
    elif (m := re.match(r"[A-Z]+\d+x\d+x(\d+(?:p\d+)?)", upper)):
        dims.append(f"{m.group(1).replace('p', '.')} mm wall thickness")
    if fillet:
        dims.append(f"{fillet} mm internal corner fillet")
    return f"A {material} rectangular box-section tube" + _emit(dims)


def prompt_antenna(f, c, d):
    L = get(f, "length")
    top_d = get(f, "top_d")
    bot_d = get(f, "bot_d")
    split = get(f, "split")
    straight = get(f, "straight")
    gap = get(f, "gap")
    dims = []
    if L:        dims.append(f"{L} mm total length")
    if bot_d:    dims.append(f"{bot_d} mm base diameter")
    if top_d:    dims.append(f"{top_d} mm tip diameter")
    if straight: dims.append(f"{straight} mm fixed straight section")
    if split:    dims.append(f"pivot {split} mm from the base")
    if gap:      dims.append(f"{gap} mm panel gap for washers and nuts")
    return "A folding whip RF antenna module" + _emit(dims)


def prompt_7_segment(f, c, d):
    size = _parse_vec(f.get("segment_size", ""))
    digit = _parse_vec(f.get("segment_digit_size", ""))
    pins = _parse_vec(f.get("segment_pins", ""))
    dims = []
    if size and len(size) >= 3 and all(x is not None for x in size[:3]):
        dims.append(f"{size[0]:g} mm x {size[1]:g} mm body, {size[2]:g} mm thick")
    if digit and len(digit) >= 3 and all(x is not None for x in digit[:3]):
        dims.append(f"{digit[0]:g} mm wide x {digit[1]:g} mm tall digits, {digit[2]:g} mm segment width")
    if pins and len(pins) >= 2 and pins[0] is not None and pins[1] is not None:
        dims.append(f"{int(pins[0])} x {int(pins[1])} pin grid")
    return "A seven-segment LED display module" + _emit(dims)


def prompt_extrusion_bracket(f, c, d):
    size = _parse_vec(f.get("inner_corner_bracket_size", ""))
    th_base = num(f, "corner_bracket_base_thickness", "base_thickness")
    th_side = num(f, "corner_bracket_side_thickness", "side_thickness")
    offset = num(f, "corner_bracket_hole_offset", "hole_offset")
    dims = []
    if size and len(size) >= 3 and all(x is not None for x in size[:3]):
        dims.append(f"{size[0]:g} mm x {size[1]:g} mm x {size[2]:g} mm envelope")
    if th_base: dims.append(f"{th_base} mm base thickness")
    if th_side: dims.append(f"{th_side} mm side-wing thickness")
    if offset:  dims.append(f"{offset} mm hole offset from corner")
    return "An aluminium-extrusion corner bracket" + _emit(dims)


def prompt_hdpe(f, c, d):
    return "A generic component."  # unused placeholder


FAMILY_PROMPTERS = {
    "ball_bearing": prompt_ball_bearing,
    "screw": prompt_screw,
    "nut": prompt_nut,
    "washer": prompt_washer,
    "extrusion": prompt_extrusion,
    "pulley": prompt_pulley,
    "pcb": prompt_pcb,
    "sheet": prompt_sheet,
    "linear_bearing": prompt_linear_bearing,
    "insert": prompt_insert,
    "tubing": prompt_tubing,
    "ht_pipe": prompt_ht_pipe,
    "led": prompt_led,
    "smd": prompt_smd,
    "rail": prompt_rail,
    "radial": prompt_radial,
    "axial": prompt_axial,
    "batterie": prompt_ball_batt,
    "bldc_motor": prompt_bldc,
    "stepper_motor": prompt_stepper_motor,
    "camera": prompt_camera,
    "display": prompt_display,
    "panel_meter": prompt_panel_meter,
    "mains_socket": prompt_mains_socket,
    "iec": prompt_iec,
    "magnet": prompt_magnet,
    "d_connector": prompt_d_connector,
    "blower": prompt_blower,
    "transformer": prompt_transformer,
    "gear_motor": prompt_gear_motor,
    "servo_motor": prompt_servo_motor,
    "hot_end": prompt_hot_end,
    "pillar": prompt_pillar,
    "ring_terminal": prompt_ring_terminal,
    "rod_end": prompt_rod_end,
    "shaft_coupling": prompt_shaft_coupling,
    "sk_bracket": prompt_sk_bracket,
    "sbr_rail": prompt_sbr_rail,
    "bearing_block": prompt_bearing_block,
    "pillow_block": prompt_pillow_block,
    "light_strip": prompt_light_strip,
    "psu": prompt_psu,
    "ssr": prompt_ssr,
    "potentiometer": prompt_potentiometer,
    "leadnut": prompt_leadnut,
    "photo_interrupter": prompt_photo_interrupter,
    "toggle": prompt_toggle,
    "swiss_clip": prompt_swiss_clip,
    "component": prompt_component,
    "variac": prompt_variac,
    "box_section": prompt_box_section,
    "antenna": prompt_antenna,
    "7_segment": prompt_7_segment,
    "extrusion_bracket": prompt_extrusion_bracket,
}


def generic_prompt(family: str, fields: dict[str, str], c: str, d: str | None) -> str:
    head = f"A {family.replace('_', ' ')} component"
    dims = []
    for k in ("length", "width", "height", "depth", "diameter", "od", "bore", "thickness"):
        v = get(fields, k)
        if v:
            dims.append(f"{v} mm {k.replace('_', ' ')}")
    return head + (": " + ", ".join(dims) + "." if dims else ".")


# ---------------------------------------------------------------------------
# Main build
# ---------------------------------------------------------------------------

def main() -> None:
    # Build schema + constants cache per family
    schemas: dict[str, list[tuple[int, str, str]]] = {}
    constants: dict[str, dict[str, list[str]]] = {}
    for family in sorted({f.stem.split("__")[0] for f in SCAD_DIR.glob("*.scad")}):
        mod = family_module(family)
        schemas[family] = parse_accessors(VIT / f"{mod}.scad")
        constants[family] = parse_constants(VIT / family_constants_file(family))

    # Enumerate successful renders = STL files in stl/
    stl_names = {p.stem for p in STL_DIR.glob("*.stl")}
    all_ids = sorted(p.stem for p in SCAD_DIR.glob("*.scad") if p.stem in stl_names)

    entries = []
    scores: list[float] = []
    for cid in all_ids:
        scad_path = SCAD_DIR / f"{cid}.scad"
        header = parse_scad_header(scad_path)
        family = header.get("family") or cid.split("__", 1)[0]
        type_const = header.get("type_constant") or cid.split("__", 1)[1]
        mod_call = header.get("module_call", "")
        m_mod = re.match(r"([A-Za-z0-9_]+)\s*\(", mod_call)
        module_fn = m_mod.group(1) if m_mod else ""
        desc = header.get("description")

        schema = schemas.get(family, [])
        raw_values = constants.get(family, {}).get(type_const, [])
        fields = fields_dict(schema, raw_values)

        field_names = build_field_names(schema, len(raw_values))
        field_values = [fmt_num(v) or v for v in raw_values]
        dimensions = {name: (fmt_num(val) or val) for name, val in zip(field_names, raw_values)}

        # Complexity: drive tiering from the richness of the geometric
        # specification (parameter count + nesting) rather than the tiny
        # single-call SCAD source.
        complexity = compute_complexity(scad_path.read_text())
        param_count = len(raw_values)
        nested_vec = sum("[" in v for v in raw_values)
        geom_score = param_count + 2 * nested_vec
        complexity["parameter_count"] = param_count
        complexity["sub_vector_count"] = nested_vec
        complexity["complexity_score"] = round(geom_score, 2)

        # Prompt
        prompter = FAMILY_PROMPTERS.get(family)
        raw_fields = dict(zip(field_names, raw_values))
        try:
            if prompter:
                prompt = prompter(raw_fields, type_const, desc)
            else:
                prompt = generic_prompt(family, raw_fields, type_const, desc)
        except Exception:
            prompt = generic_prompt(family, raw_fields, type_const, desc)
        prompt = fix_articles(prompt)

        entries.append({
            "id": cid,
            "type_constant": type_const,
            "module_function": module_fn,
            "scad_call": mod_call,
            "component_family": family,
            "module_file": f"{family_module(family)}.scad",
            "category_file": family_constants_file(family),
            "display_name": type_const,
            "description": desc,
            "field_names": field_names,
            "field_values": field_values,
            "dimensions": dimensions,
            "scad_file": f"scad/{cid}.scad",
            "stl_file": f"stl/{cid}.stl",
            **complexity,
            "prompt": prompt,
        })
        scores.append(complexity["complexity_score"])

    # Tier boundaries via 1/3, 2/3 quantiles (like the old file)
    scores_sorted = sorted(scores)
    n = len(scores_sorted)
    q1 = scores_sorted[n // 3]
    q2 = scores_sorted[2 * n // 3]

    for e in entries:
        s = e["complexity_score"]
        e["tier"] = "Simple" if s <= q1 else ("Medium" if s <= q2 else "Complex")

    out = {
        "version": "2.0",
        "total": len(entries),
        "generated_by": "build_ground_truth.py (prompts authored by Claude Opus 4.7)",
        "tier_boundaries": {"simple_max": q1, "medium_max": q2},
        "components": entries,
    }
    OUT.write_text(json.dumps(out, indent=2))
    print(f"Wrote {OUT} with {len(entries)} components.")


if __name__ == "__main__":
    main()
