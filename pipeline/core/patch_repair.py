"""
CRAFT v2 Patch Repair (Phase B.9)

Targeted plan repair using RFC-6902-style JSON Patch operations. Replaces
the v1 "regenerate the whole plan from scratch" fallback: when Stage 6
unified feedback emits :class:`PatchHint` objects, this module translates
them into concrete edits on the plan dict, validates the result, and hands
the patched plan back for recompilation. Prior good work is preserved
instead of being thrown away.

We use a minimal RFC 6902 subset plus one convenience extension:

  - ``add``      — insert into an object key or append to a list
  - ``replace``  — overwrite an existing value
  - ``remove``   — delete an object key or a list element
  - ``-`` suffix — appending to a list (spec-compliant)
  - ``[-]`` suffix in dotted paths — same meaning, used in PatchHint
    targets (we normalize both forms).

Dotted-path style (``parameters.body_length`` or
``geometry.base_shapes[0].type``) is the human-friendly form used in
:class:`PatchHint`. It is translated to real JSON-pointer tokens before
the patch is applied.
"""

from __future__ import annotations

import copy
import json
import re
from dataclasses import dataclass, field, asdict
from typing import Any, Dict, List, Optional, Tuple

from .unified_feedback import PatchHint, FeedbackResult


# =============================================================================
# Path translation
# =============================================================================

_INDEX_RE = re.compile(r'\[(-?\d+|-)\]$')


def _dotted_to_pointer(path: str) -> str:
    """
    Convert ``geometry.base_shapes[-]`` / ``parameters.body_length`` into a
    JSON pointer string. Returns ``""`` for the root. Handles the ``[-]``
    append marker and numeric indices.
    """
    if not path or path == "/":
        return ""
    tokens: List[str] = []
    for segment in path.split("."):
        segment = segment.strip()
        if not segment:
            continue
        m = _INDEX_RE.search(segment)
        if m:
            name = segment[: m.start()]
            if name:
                tokens.append(name)
            tokens.append(m.group(1))
        else:
            tokens.append(segment)
    escaped = [t.replace("~", "~0").replace("/", "~1") for t in tokens]
    return "/" + "/".join(escaped)


def _resolve(doc: Any, tokens: List[str]) -> Tuple[Any, Any, Optional[Any]]:
    """Walk ``tokens`` through ``doc``. Returns (parent, last_token, value)."""
    if not tokens:
        return None, None, doc
    node = doc
    for t in tokens[:-1]:
        if isinstance(node, list):
            node = node[int(t)]
        elif isinstance(node, dict):
            node = node[t]
        else:
            raise KeyError(f"cannot traverse into {type(node).__name__} at {t}")
    last = tokens[-1]
    try:
        if isinstance(node, list):
            if last == "-":
                value: Optional[Any] = None
            else:
                value = node[int(last)]
        elif isinstance(node, dict):
            value = node.get(last)
        else:
            value = None
    except (IndexError, KeyError):
        value = None
    return node, last, value


# =============================================================================
# Result dataclass
# =============================================================================

@dataclass
class PatchApplyResult:
    """Outcome of applying a batch of patches to a plan."""
    original_plan: Dict[str, Any]
    patched_plan: Dict[str, Any]
    applied: List[Dict[str, Any]] = field(default_factory=list)
    skipped: List[Dict[str, Any]] = field(default_factory=list)
    errors: List[str] = field(default_factory=list)

    def success(self) -> bool:
        return bool(self.applied) and not self.errors

    def summary(self) -> str:
        return (
            f"patch applied={len(self.applied)} "
            f"skipped={len(self.skipped)} errors={len(self.errors)}"
        )

    def to_dict(self) -> Dict[str, Any]:
        return {
            "applied": list(self.applied),
            "skipped": list(self.skipped),
            "errors": list(self.errors),
        }


# =============================================================================
# Patch conversion
# =============================================================================

def hints_to_patches(hints: List[PatchHint]) -> List[Dict[str, Any]]:
    """Translate :class:`PatchHint` objects into RFC-6902 operation dicts."""
    patches: List[Dict[str, Any]] = []
    for h in hints:
        pointer = _dotted_to_pointer(h.target)
        op: Dict[str, Any] = {"op": h.op, "path": pointer}
        if h.op in ("add", "replace"):
            if isinstance(h.payload, dict) and "value" in h.payload and len(h.payload) == 1:
                op["value"] = h.payload["value"]
            else:
                op["value"] = h.payload
        patches.append(op)
    return patches


# =============================================================================
# Apply
# =============================================================================

def apply_patches(
    plan: Dict[str, Any],
    patches: List[Dict[str, Any]],
) -> PatchApplyResult:
    """
    Apply a list of RFC-6902-style ops to ``plan``. Never mutates the input.

    Unknown ops or pointers that can't be resolved are collected as
    ``errors`` rather than raised, so callers can log them and fall back.
    """
    patched = copy.deepcopy(plan)
    applied: List[Dict[str, Any]] = []
    skipped: List[Dict[str, Any]] = []
    errors: List[str] = []

    for op in patches:
        try:
            if op.get("op") == "add":
                _op_add(patched, op)
            elif op.get("op") == "replace":
                _op_replace(patched, op)
            elif op.get("op") == "remove":
                _op_remove(patched, op)
            else:
                skipped.append(op)
                continue
            applied.append(op)
        except Exception as e:
            errors.append(f"{op.get('op','?')} {op.get('path','')}: {str(e)[:100]}")
            skipped.append(op)

    return PatchApplyResult(
        original_plan=plan,
        patched_plan=patched,
        applied=applied,
        skipped=skipped,
        errors=errors,
    )


def _pointer_tokens(pointer: str) -> List[str]:
    if not pointer or pointer == "/":
        return []
    if not pointer.startswith("/"):
        raise ValueError(f"invalid pointer: {pointer!r}")
    return [
        t.replace("~1", "/").replace("~0", "~")
        for t in pointer.lstrip("/").split("/")
    ]


def _op_add(doc: Dict[str, Any], op: Dict[str, Any]) -> None:
    tokens = _pointer_tokens(op["path"])
    if not tokens:
        raise ValueError("'add' to root is not supported")
    parent, last, _existing = _resolve(doc, tokens)
    value = op.get("value")
    if isinstance(parent, list):
        if last == "-":
            parent.append(value)
        else:
            parent.insert(int(last), value)
    elif isinstance(parent, dict):
        parent[last] = value
    else:
        raise KeyError(f"cannot add under {type(parent).__name__}")


def _op_replace(doc: Dict[str, Any], op: Dict[str, Any]) -> None:
    tokens = _pointer_tokens(op["path"])
    if not tokens:
        raise ValueError("'replace' of root not supported")
    parent, last, _existing = _resolve(doc, tokens)
    value = op.get("value")
    if isinstance(parent, list):
        parent[int(last)] = value
    elif isinstance(parent, dict):
        if last not in parent:
            raise KeyError(f"cannot replace missing key {last!r}")
        parent[last] = value
    else:
        raise KeyError(f"cannot replace under {type(parent).__name__}")


def _op_remove(doc: Dict[str, Any], op: Dict[str, Any]) -> None:
    tokens = _pointer_tokens(op["path"])
    if not tokens:
        raise ValueError("'remove' of root not supported")
    parent, last, _existing = _resolve(doc, tokens)
    if isinstance(parent, list):
        del parent[int(last)]
    elif isinstance(parent, dict):
        parent.pop(last, None)
    else:
        raise KeyError(f"cannot remove under {type(parent).__name__}")


# =============================================================================
# Orchestrator
# =============================================================================

def repair_plan_from_feedback(
    plan: Dict[str, Any],
    feedback: FeedbackResult,
    validate: Optional[callable] = None,
) -> PatchApplyResult:
    """
    Main Stage 7 entry point.

    Turns the :class:`FeedbackResult`'s patch hints into RFC-6902 ops,
    applies them to a copy of ``plan``, and (optionally) runs the caller's
    ``validate`` function on the patched plan. On validation error the
    original plan is returned and the error is recorded — no silent
    corruption.
    """
    patches = hints_to_patches(feedback.patch_hints)
    result = apply_patches(plan, patches)

    if validate is not None and result.applied:
        try:
            validate(result.patched_plan)
        except Exception as e:
            result.errors.append(f"post-patch validation failed: {str(e)[:200]}")
            result.patched_plan = copy.deepcopy(plan)

    print(f"[PatchRepair] {result.summary()}")
    return result


__all__ = [
    "PatchApplyResult",
    "apply_patches",
    "hints_to_patches",
    "repair_plan_from_feedback",
]
