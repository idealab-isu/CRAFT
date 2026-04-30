"""
CRAFT v4 — Stage 3: KB reference (informational only).

Wraps the existing NopSCADlib retriever (pipeline/kb/retriever.py) with two
hard rules that fix the v1 KB-overuse failure mode:

1. STRONG MATCH ONLY. KB grounding fires only when the top retrieval result
   has score >= ``min_score`` (default 0.85). Below that, an empty hint is
   returned and Stage 0 falls back to pure GPT-5.2 prior knowledge.

2. NEVER ESSENTIAL_PARTS. The output is a free-form text block injected as
   a "reference, informational only" hint to the SCAD generator. It is
   NEVER converted into required components, never used to drive the
   acceptance-criteria check, and never referenced by the regression gate.

3. INTERNAL HELPERS FILTERED. Modules whose names look like NopSCADlib
   internal helpers (``screw_position``, ``..._hole``, ``..._profile``,
   anything starting with ``_``) are dropped from the reference block
   regardless of score, because in v1 those leaked into the
   essential_parts gate and produced bizarre helper-only outputs.

If the KB is unavailable (chromadb not installed, index missing, etc.) the
class returns empty hints silently — v4 must remain runnable on a clean
checkout without the KB built.
"""

from __future__ import annotations

import re
from dataclasses import dataclass
from typing import List, Optional


# Regex for module names that look like NopSCADlib internal helpers and
# should never leak into v4 prompts. Matches things like:
#   _foo, screw_position, head_hole, screw_profile, screw_dia, ...
_HELPER_NAME_RE = re.compile(
    r"^(_.*"
    r"|.*_position$"
    r"|.*_profile$"
    r"|.*_hole$"
    r"|.*_holes$"
    r"|.*_dia$"
    r"|.*_radius$"
    r"|.*_diameter$"
    r"|.*_inset$"
    r"|.*_offset$"
    r"|.*_clearance$"
    r"|.*_polygon$)",
    re.IGNORECASE,
)


@dataclass
class KBHint:
    """A KB hint emitted to Stage 0 / Stage 4. May be empty."""
    text: str
    matched_components: List[str]      # module names that survived filtering
    top_score: float
    fired: bool                        # True iff a usable hint was produced

    def is_empty(self) -> bool:
        return not self.fired or not self.text.strip()


class KBReference:
    """Reference-only wrapper around the v1 NopSCADlib retriever."""

    def __init__(
        self,
        min_score: float = 0.85,
        top_k: int = 2,
        max_hint_chars: int = 1500,
    ):
        """
        Args:
            min_score: Cosine threshold for the top retrieval result.
            top_k: How many components to include in the hint block.
            max_hint_chars: Truncate the final hint to this many characters
                so we never blow up the system prompt.
        """
        self.min_score = min_score
        self.top_k = top_k
        self.max_hint_chars = max_hint_chars
        self._retriever = self._lazy_load_retriever()

    def lookup(self, prompt: str) -> KBHint:
        """Return a (possibly empty) reference hint for a user prompt."""
        if self._retriever is None:
            return KBHint(text="", matched_components=[], top_score=0.0, fired=False)

        try:
            ctx = self._retriever.retrieve(prompt)
        except Exception:
            return KBHint(text="", matched_components=[], top_score=0.0, fired=False)

        if not ctx or not ctx.results:
            return KBHint(text="", matched_components=[], top_score=0.0, fired=False)

        # Strip helpers and below-threshold results.
        survivors = []
        for r in ctx.results[: self.top_k * 3]:  # over-pull, then filter
            module_name = getattr(r.component, "module_name", "") or ""
            if _HELPER_NAME_RE.match(module_name):
                continue
            if r.score < self.min_score:
                continue
            survivors.append(r)
            if len(survivors) >= self.top_k:
                break

        if not survivors:
            top_score = ctx.results[0].score if ctx.results else 0.0
            return KBHint(
                text="",
                matched_components=[],
                top_score=top_score,
                fired=False,
            )

        text = self._format_hint(survivors)
        if len(text) > self.max_hint_chars:
            text = text[: self.max_hint_chars] + "\n... [truncated]"

        return KBHint(
            text=text,
            matched_components=[r.component.module_name for r in survivors],
            top_score=survivors[0].score,
            fired=True,
        )

    # ------------------------------------------------------------------
    # Private helpers
    # ------------------------------------------------------------------

    def _lazy_load_retriever(self) -> Optional[object]:
        """Load the retriever, swallowing any errors (KB is optional)."""
        try:
            from kb.retriever import KnowledgeRetriever  # type: ignore
            return KnowledgeRetriever()
        except Exception:
            try:
                # When called as `pipeline.v4.kb_reference`
                from pipeline.kb.retriever import KnowledgeRetriever  # type: ignore
                return KnowledgeRetriever()
            except Exception:
                return None

    def _format_hint(self, results) -> str:
        """Render a small Markdown block, labelled as reference-only."""
        lines = [
            "The following NopSCADlib modules MAY be relevant. Treat them as a"
            " reference only — copy dimensions, not structure, and do not"
            " include their helper modules.",
            "",
        ]
        for r in results:
            comp = r.component
            module_code = getattr(comp, "module_code", "") or ""
            # Trim long source code so the hint stays compact.
            snippet = module_code[:600].rstrip()
            lines.append(f"- **{comp.module_name}** (score={r.score:.2f})")
            desc = getattr(comp, "description", "") or ""
            if desc:
                lines.append(f"  description: {desc}")
            if snippet:
                lines.append("  reference snippet:")
                lines.append("  ```openscad")
                for ln in snippet.splitlines():
                    lines.append(f"  {ln}")
                lines.append("  ```")
            lines.append("")
        return "\n".join(lines)
