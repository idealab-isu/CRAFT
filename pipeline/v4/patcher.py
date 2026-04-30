"""
CRAFT v4 — Stage 5: Single targeted SCAD patch.

The patcher takes:
    - The original prompt.
    - The BASELINE SCAD (we always patch from baseline, never from a previous
      patch, to avoid iterative drift).
    - The structured GapReport from the gap assessor.
    - Optional KB hint.

It emits a SINGLE patched SCAD program. The model is instructed to make the
smallest change that addresses ``patch_priority`` and ``critical_issues``,
and to preserve the parametric header from the baseline whenever possible
(so editability is not lost in repair).

Crucially, the patcher is ALSO instructed to bail out (return the baseline
unchanged) if it cannot make a confident, targeted improvement. The
non-regression gate downstream will discard low-quality patches anyway,
but giving the patcher the option to no-op reduces noise.
"""

from __future__ import annotations

import os
import re
import time
from dataclasses import dataclass
from typing import Optional

from openai import OpenAI


PATCH_SYSTEM_PROMPT = """You are an OpenSCAD repair specialist. You will receive:
- The original user request.
- A baseline OpenSCAD program (already parametric).
- A structured gap report listing acceptance-criteria failures, critical
  issues, and a prioritised list of fixes.

Your job is to produce ONE targeted patched program that addresses as many
of the prioritised fixes as possible WITHOUT introducing new problems.

HARD RULES:

1. PRESERVE THE PARAMETRIC HEADER. Keep the baseline's parameter block,
   `// [min:max]` ranges, and parameter names. You may add new parameters
   if needed, but do NOT inline magic numbers into the geometry.

2. MINIMAL CHANGE. Do not rewrite the program from scratch. Touch only the
   parts that need to change to address the prioritised fixes.

3. RESPECT SCOPE. Do NOT add display stands, demonstration scenes, PCBs,
   bases, or annotations unless the user explicitly asked for them. If
   the gap report says scope creep is a critical issue, DELETE the
   offending parts.

4. ONE CONNECTED SOLID. The output must remain one connected solid (use
   small overlaps `eps = 0.5 mm` when joining shapes) unless the prompt
   explicitly asked for separable parts.

5. NO-OP IS ALLOWED. If you cannot make a confident, targeted improvement,
   return the BASELINE program unchanged. The downstream gate prefers a
   correct baseline over a confidently wrong patch.

6. OUTPUT FORMAT. Output ONLY raw OpenSCAD code. No markdown fences, no
   commentary, no JSON. The first non-whitespace character must begin the
   parameter block.
"""


PATCH_USER_TEMPLATE = """USER REQUEST:
{prompt}

BASELINE SCAD:
```openscad
{baseline_scad}
```

GAP REPORT (critical first):

Critical issues:
{critical_block}

Patch priorities (in order):
{priority_block}

Failed acceptance criteria:
{failed_block}

{kb_block}

Produce the patched SCAD now. Output raw OpenSCAD only — no markdown."""


@dataclass
class PatchOutput:
    """Result of one patch attempt."""
    code: str
    raw_response: str
    elapsed_s: float
    model: str
    is_noop: bool          # True if patcher returned baseline essentially unchanged
    error: Optional[str] = None

    @property
    def ok(self) -> bool:
        return bool(self.code) and self.error is None


class SCADPatcher:
    """Single-shot SCAD patcher. Always reads from baseline, never from a
    previous patch."""

    def __init__(
        self,
        client: Optional[OpenAI] = None,
        model: str = "gpt-5.2",
        temperature: float = 0.1,
        max_tokens: int = 4000,
    ):
        self.client = client or OpenAI(api_key=os.getenv("OPENAI_API_KEY"))
        self.model = model
        self.temperature = temperature
        self.max_tokens = max_tokens

    def patch(
        self,
        prompt: str,
        baseline_scad: str,
        gap_report,                      # type: GapReport
        kb_hint: Optional[str] = None,
    ) -> PatchOutput:
        critical_block = (
            "\n".join(f"- {x}" for x in gap_report.critical_issues) or "- (none reported)"
        )
        priority_block = (
            "\n".join(f"{i+1}. {x}" for i, x in enumerate(gap_report.patch_priority))
            or "1. (none reported)"
        )
        failed = [c for c in gap_report.acceptance_criteria if not c.passed]
        failed_block = (
            "\n".join(
                f"- {c.id}: {c.description} (verdict={c.verdict}; saw: {c.evidence})"
                for c in failed
            )
            or "- (none reported)"
        )
        kb_block = (
            "Reference (informational only):\n" + kb_hint
            if kb_hint else ""
        )

        user_msg = PATCH_USER_TEMPLATE.format(
            prompt=prompt,
            baseline_scad=baseline_scad,
            critical_block=critical_block,
            priority_block=priority_block,
            failed_block=failed_block,
            kb_block=kb_block,
        )

        start = time.time()
        try:
            kwargs = {
                "model": self.model,
                "messages": [
                    {"role": "system", "content": PATCH_SYSTEM_PROMPT},
                    {"role": "user", "content": user_msg},
                ],
                "temperature": self.temperature,
            }
            if self.model in {"gpt-5.1", "gpt-5.2", "o1", "o1-mini", "o3", "o3-mini"}:
                kwargs["max_completion_tokens"] = self.max_tokens
            else:
                kwargs["max_tokens"] = self.max_tokens

            response = self.client.chat.completions.create(**kwargs)
            raw = (response.choices[0].message.content or "").strip()
            code = self._strip_markdown(raw)
            is_noop = self._is_noop(baseline_scad, code)

            return PatchOutput(
                code=code,
                raw_response=raw,
                elapsed_s=time.time() - start,
                model=self.model,
                is_noop=is_noop,
            )
        except Exception as e:
            return PatchOutput(
                code="",
                raw_response="",
                elapsed_s=time.time() - start,
                model=self.model,
                is_noop=False,
                error=str(e),
            )

    @staticmethod
    def _strip_markdown(text: str) -> str:
        if "```" not in text:
            return text.strip()
        m = re.search(r"```(?:openscad|scad)?\s*\n?(.*?)```", text, re.DOTALL)
        return m.group(1).strip() if m else text.strip()

    @staticmethod
    def _is_noop(baseline: str, patched: str) -> bool:
        """Detect when the patcher returned the baseline (or near-identical)."""
        b = re.sub(r"\s+", " ", baseline.strip())
        p = re.sub(r"\s+", " ", patched.strip())
        return b == p
