"""
CRAFT v4 — Stage 4: VLM gap assessor.

Single GPT-5.2 vision call. Inputs:
  - Original natural-language prompt.
  - 8 rendered views (6 ortho + 2 iso) of the candidate SCAD output.
  - Optional reference sketch / image (for image-conditioned mode).

Returns a structured ``GapReport``:
  - ``acceptance_criteria``: list of testable predicate verdicts derived
    from the prompt (has_part / count / spatial / proportion). Each
    criterion has ``id``, ``description``, ``verdict`` ∈ {pass, fail, unsure}.
  - ``critical_issues``: free-form list of major problems (broken
    geometry, scope creep, missing essential structure).
  - ``minor_issues``: smaller polish items.
  - ``patch_priority``: short ordered list of what a single patch
    should target if invoked.

KEY DESIGN NOTE:
The "criteria pass count" returned here is the ONE inference-time signal
that drives the regression gate. Ground truth is never used. To keep the
signal robust, the assessor is asked to decide criteria deterministically
("pass" / "fail" / "unsure", with "unsure" treated as "fail" downstream).
"""

from __future__ import annotations

import base64
import json
import os
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Dict, List, Optional

# Pipeline-root import shim (mirrors render_check.py).
_PIPELINE_ROOT = Path(__file__).resolve().parent.parent
if str(_PIPELINE_ROOT) not in sys.path:
    sys.path.insert(0, str(_PIPELINE_ROOT))


GAP_ASSESS_SYSTEM_PROMPT = """You are a CAD reviewer. You will be shown:
- A natural-language design request.
- Eight rendered views of a candidate 3D model (6 orthographic + 2 isometric).
- Optionally, a reference sketch the user provided.

Your job is to produce a STRUCTURED gap report (JSON only). The report has:

1. acceptance_criteria: an array of testable predicates derived from the
   prompt. Each entry MUST have:
       - "id": short stable identifier (e.g. "has_pulley", "wheels_count_4")
       - "description": one sentence of what is being checked
       - "verdict": "pass" | "fail" | "unsure"
       - "evidence": one sentence describing what you saw across the views
   Generate at least 3 criteria but no more than 8. Cover:
   essential parts present, counts of repeated parts, key spatial relations
   ("on top of", "centered", "through", "around"), and overall silhouette
   sanity.

2. critical_issues: array of strings. Use this for problems that would
   make any reasonable user reject the model — empty/blank renders,
   missing essential structure, scope creep (extra parts the user did NOT
   ask for, like display stands, demonstration scenes, PCBs), broken
   topology, parts that float in mid-air, etc.

3. minor_issues: array of strings. Polish items that don't justify
   rejecting the model.

4. patch_priority: array of strings, ordered. The TOP suggestion is what
   a single targeted patch should address first. Be concrete (e.g.
   "add 4 wheels at the corners of the chassis at z=0", not
   "make it look more like a car").

5. overall_judgement: "good" | "acceptable" | "poor"

Rules:
- Be conservative. If you cannot verify a criterion from the views, mark
  it "unsure", not "pass".
- Do NOT hallucinate parts that aren't visible in the renders.
- If the renders are blank or empty, every criterion is "fail" and
  overall_judgement is "poor".
- Output JSON only, no commentary, no markdown fences.
"""


GAP_ASSESS_USER_TEMPLATE = """REQUEST:
{prompt}

The eight views below show: {view_order}.
{sketch_note}{kb_note}

Produce the gap report as JSON. JSON only, no markdown."""


@dataclass
class AcceptanceCriterion:
    """One testable predicate derived from the prompt."""
    id: str
    description: str
    verdict: str        # "pass" | "fail" | "unsure"
    evidence: str = ""

    @property
    def passed(self) -> bool:
        return self.verdict == "pass"


@dataclass
class GapReport:
    """Structured output of the gap assessor."""
    acceptance_criteria: List[AcceptanceCriterion] = field(default_factory=list)
    critical_issues: List[str] = field(default_factory=list)
    minor_issues: List[str] = field(default_factory=list)
    patch_priority: List[str] = field(default_factory=list)
    overall_judgement: str = "poor"
    raw_response: str = ""
    error: Optional[str] = None

    @property
    def num_pass(self) -> int:
        return sum(1 for c in self.acceptance_criteria if c.passed)

    @property
    def num_total(self) -> int:
        return len(self.acceptance_criteria)

    @property
    def fitness_proxy(self) -> float:
        """Inference-only fitness in [0, 1]. Used for logging only."""
        if self.num_total == 0:
            return 0.0
        return self.num_pass / self.num_total

    def needs_patch(self) -> bool:
        """Should we attempt a single patch?"""
        if self.error:
            return False
        if self.overall_judgement == "good" and not self.critical_issues:
            return False
        return True


class GapAssessor:
    """Single VLM call producing a GapReport."""

    def __init__(
        self,
        client,
        model: str = "gpt-5.2",
        max_output_tokens: int = 2000,
        temperature: float = 0.1,
    ):
        self.client = client
        self.model = model
        self.max_output_tokens = max_output_tokens
        self.temperature = temperature

    def assess(
        self,
        prompt: str,
        view_paths: Dict[str, str],
        sketch_path: Optional[str] = None,
        kb_hint: Optional[str] = None,
    ) -> GapReport:
        """Run one VLM call and parse the structured report."""
        view_order = ", ".join(view_paths.keys())
        user_text = GAP_ASSESS_USER_TEMPLATE.format(
            prompt=prompt,
            view_order=view_order,
            sketch_note=(
                "\nA REFERENCE sketch is also provided — use it to judge "
                "topology and silhouette only, not absolute dimensions.\n"
                if sketch_path else ""
            ),
            kb_note=(
                "\nA KB reference block is provided as context — informational only.\n"
                if kb_hint else ""
            ),
        )

        try:
            raw = self._call_vision(prompt_text=user_text,
                                    view_paths=view_paths,
                                    sketch_path=sketch_path)
            report = self._parse(raw)
            report.raw_response = raw
            return report
        except Exception as e:
            return GapReport(error=f"gap assessor failed: {e}")

    # ------------------------------------------------------------------
    # Vision call dispatch (Responses API for GPT-5.2, Chat for GPT-4o)
    # ------------------------------------------------------------------

    def _call_vision(
        self,
        prompt_text: str,
        view_paths: Dict[str, str],
        sketch_path: Optional[str],
    ) -> str:
        if self.model in {"gpt-5.2"}:
            return self._call_responses_api(prompt_text, view_paths, sketch_path)
        return self._call_chat_completions(prompt_text, view_paths, sketch_path)

    def _call_responses_api(
        self,
        prompt_text: str,
        view_paths: Dict[str, str],
        sketch_path: Optional[str],
    ) -> str:
        parts: list = [
            {"type": "input_text", "text": GAP_ASSESS_SYSTEM_PROMPT + "\n\n" + prompt_text},
        ]
        if sketch_path and os.path.exists(sketch_path):
            parts.append({"type": "input_text", "text": "\nReference sketch:"})
            parts.append({"type": "input_image", "image_url": _b64_data_url(sketch_path)})
        for view_name, path in view_paths.items():
            if not os.path.exists(path):
                continue
            parts.append({"type": "input_text", "text": f"\n{view_name.upper()} VIEW:"})
            parts.append({"type": "input_image", "image_url": _b64_data_url(path)})

        response = self.client.responses.create(
            model=self.model,
            input=[{"role": "user", "content": parts}],
            temperature=self.temperature,
            max_output_tokens=self.max_output_tokens,
            text={"format": {"type": "json_object"}},
        )
        return response.output_text or ""

    def _call_chat_completions(
        self,
        prompt_text: str,
        view_paths: Dict[str, str],
        sketch_path: Optional[str],
    ) -> str:
        parts: list = [
            {"type": "text", "text": GAP_ASSESS_SYSTEM_PROMPT + "\n\n" + prompt_text},
        ]
        if sketch_path and os.path.exists(sketch_path):
            parts.append({"type": "text", "text": "\nReference sketch:"})
            parts.append({"type": "image_url", "image_url": {"url": _b64_data_url(sketch_path)}})
        for view_name, path in view_paths.items():
            if not os.path.exists(path):
                continue
            parts.append({"type": "text", "text": f"\n{view_name.upper()} VIEW:"})
            parts.append({"type": "image_url", "image_url": {"url": _b64_data_url(path)}})

        kwargs = {
            "model": self.model,
            "messages": [{"role": "user", "content": parts}],
            "temperature": self.temperature,
            "response_format": {"type": "json_object"},
        }
        if self.model in {"gpt-5.1", "gpt-5.2"}:
            kwargs["max_completion_tokens"] = self.max_output_tokens
        else:
            kwargs["max_tokens"] = self.max_output_tokens

        response = self.client.chat.completions.create(**kwargs)
        return response.choices[0].message.content or ""

    # ------------------------------------------------------------------
    # JSON parsing
    # ------------------------------------------------------------------

    @staticmethod
    def _parse(raw: str) -> GapReport:
        cleaned = raw.strip()
        if cleaned.startswith("```"):
            m = re.search(r"```(?:json)?\s*\n?(.*?)```", cleaned, re.DOTALL)
            if m:
                cleaned = m.group(1).strip()
        try:
            data = json.loads(cleaned)
        except Exception as e:
            return GapReport(error=f"JSON parse failed: {e}", raw_response=raw)

        criteria = []
        for c in data.get("acceptance_criteria") or []:
            criteria.append(
                AcceptanceCriterion(
                    id=str(c.get("id", "")),
                    description=str(c.get("description", "")),
                    verdict=str(c.get("verdict", "unsure")).lower(),
                    evidence=str(c.get("evidence", "")),
                )
            )

        return GapReport(
            acceptance_criteria=criteria,
            critical_issues=[str(x) for x in (data.get("critical_issues") or [])],
            minor_issues=[str(x) for x in (data.get("minor_issues") or [])],
            patch_priority=[str(x) for x in (data.get("patch_priority") or [])],
            overall_judgement=str(data.get("overall_judgement", "poor")).lower(),
        )


def _b64_data_url(image_path: str) -> str:
    """Encode a PNG (or JPG) at ``image_path`` as a base64 data URL."""
    with open(image_path, "rb") as f:
        data = base64.b64encode(f.read()).decode("ascii")
    suffix = os.path.splitext(image_path)[1].lower().strip(".") or "png"
    return f"data:image/{suffix};base64,{data}"
