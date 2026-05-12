"""
CRAFT v3 — sketch- and prompt-grounded gap refinement

Flow (orchestrated by app.CRAFTPipeline when CRAFT_VERSION=3):
1. Baseline SCAD already exists (plan → compile → initial render).
2. Optional intent sketch (from brief) + six orthographic renders of baseline.
3. One VLM call: structured JSON gap list (add / remove / connectivity) vs sketch+text.
4. One text-only LLM call: apply gaps surgically to OpenSCAD — no multi-iterate VLM loop.
"""

from __future__ import annotations

import base64
import json
import os
import re
import tempfile
from dataclasses import dataclass, field
from typing import Any, Callable, Dict, List, Optional

from utils.rendering import MultiViewRenderer

# Keep preview renders fast (same philosophy as VisualSelfCorrector)
_INITIAL_TIMEOUT = int(os.getenv("INITIAL_RENDER_TIMEOUT", "60"))
_ITER_FN = 32

ORTHO_VIEW_NAMES = ["front", "back", "left", "right", "top", "bottom"]

NEW_API_MODELS = {"gpt-5.1", "gpt-5.2", "o1", "o1-mini", "o1-preview", "o3", "o3-mini"}
RESPONSES_API_VISION_MODELS = {"gpt-5.2"}
REASONING_MODELS = {"gpt-5.2", "o1", "o1-mini", "o1-preview", "o3", "o3-mini"}

GAP_ANALYSIS_PROMPT = """You are doing a SINGLE structured review for CRAFT v3 gap refinement.

TARGET INTENT (what we want):
---
{original_prompt}
---

EXPECTED PARTS (names — not all may be visible as separate solids):
{expected_parts}

The images after this message are:
1) OPTIONAL: a design-intent sketch (if present) — loose reference for silhouette and major features, not a CAD spec.
2) Six orthographic renders of the CURRENT OpenSCAD model (front, back, left, right, top, bottom).

Your job: compare TARGET vs CURRENT. List ONLY actionable, concrete deltas.
- Prefer **add** when a part or feature is clearly missing vs the prompt/sketch.
- Prefer **remove** for unrequested extras (display bases, PCBs, stands) not in the prompt.
- **fix_connectivity** when parts that should touch are visibly floating or separated.

Rules:
- If the current model already matches intent well enough, set no_changes_needed true and empty gaps.
- Be conservative: do not invent cosmetic details; only fix clear gaps.
- Do not ask to add text/labels/logos.

Respond with JSON ONLY:
{{
  "no_changes_needed": true/false,
  "gaps": [
    {{
      "id": "g1",
      "action": "add" | "remove" | "fix_connectivity",
      "description": "one short imperative sentence an OpenSCAD expert can follow"
    }}
  ],
  "rationale": "one or two sentences"
}}
"""

GAP_ANALYSIS_PROMPT_VIEWS = """You are doing a SINGLE structured review for CRAFT v3 gap refinement (IMAGE-ONLY mode).

There is no text prompt. The TARGET is the 3D shape shown in {n_target_views}
reference renders below — those views ARE the spec.

The images after this message are, in order:
  1) {n_target_views} TARGET reference views of the shape we want to reproduce
     (rendered from 4 front-facing and 4 rear-facing camera angles by the
     Zero-to-CAD harness; viewpoints are NOT labeled).
  2) Six orthographic renders of the CURRENT OpenSCAD model
     (front, back, left, right, top, bottom).

Your job: compare TARGET vs CURRENT and list ONLY actionable, concrete deltas.
- **add** for parts/features visible in the TARGET but missing from CURRENT.
- **remove** for extras present in CURRENT but not in the TARGET.
- **fix_connectivity** when parts that should touch are visibly floating.
- **adjust_proportions** when overall shape is right but dimensions are clearly off.

Rules:
- The TARGET views are the authority. Do not invent details not visible there.
- Cross-reference multiple views before listing a gap (a feature might be
  hidden in one view but visible in another).
- If CURRENT already matches TARGET well enough, set no_changes_needed true.
- Do not ask to add text/labels/logos/decorative noise.

Respond with JSON ONLY:
{{
  "no_changes_needed": true/false,
  "gaps": [
    {{
      "id": "g1",
      "action": "add" | "remove" | "fix_connectivity" | "adjust_proportions",
      "description": "one short imperative sentence an OpenSCAD expert can follow"
    }}
  ],
  "rationale": "one or two sentences explaining the overall delta",
  "match_confidence": 0.0
}}
"""


APPLY_GAPS_PROMPT = """You are patching existing OpenSCAD for CRAFT v3. Apply ONLY the listed gaps.
Do not redesign from scratch. Preserve parametric variables and structure where possible.

USER REQUEST (authoritative scope):
{original_prompt}

GAPS TO ADDRESS (complete all that are feasible in one edit):
{gaps_json}

RULES:
- Minimal diff: add small modules or union() sections, remove modules/geometry for "remove" gaps, adjust translate/union for connectivity.
- Do NOT add display stands, PCBs, or scene props unless a gap explicitly asks.
- Output ONE valid OpenSCAD program. No markdown, no prose.

CURRENT CODE:
```openscad
{current_code}
```
"""


@dataclass
class GapRefinementResult:
    """Outcome of the v3 gap-refinement stage."""

    success: bool
    final_code: str
    applied_patch: bool
    analysis: Dict[str, Any] = field(default_factory=dict)
    view_images: Dict[str, str] = field(default_factory=dict)
    error: Optional[str] = None


class GapRefiner:
    """Baseline render → gap analysis → single surgical code patch."""

    def __init__(
        self,
        client: Any,
        model: str,
        image_dir: str = "static/images",
    ):
        self.client = client
        self.model = model
        self.image_dir = image_dir
        self.renderer = MultiViewRenderer(
            imgsize=(400, 400),
            distance=200,
            timeout=_INITIAL_TIMEOUT,
            fn_override=_ITER_FN,
        )

    def _get_token_param(self, max_tokens: int) -> Dict[str, int]:
        if self.model in NEW_API_MODELS:
            return {"max_completion_tokens": max_tokens}
        return {"max_tokens": max_tokens}

    @staticmethod
    def _image_to_base64(image_path: str) -> str:
        with open(image_path, "rb") as f:
            b64 = base64.b64encode(f.read()).decode("utf-8")
        return f"data:image/png;base64,{b64}"

    def _extract_json(self, text: str) -> Dict[str, Any]:
        text = text.strip()
        try:
            return json.loads(text)
        except json.JSONDecodeError:
            pass
        m = re.search(r"\{[\s\S]*\}", text)
        if m:
            try:
                return json.loads(m.group())
            except json.JSONDecodeError:
                pass
        return {}

    def _extract_scad(self, text: str) -> str:
        pat = r"```(?:openscad|scad)?\s*([\s\S]*?)```"
        m = re.findall(pat, text)
        if m:
            return m[0].strip()
        t = text.strip()
        if t.startswith("```"):
            lines = t.split("\n")
            t = "\n".join(lines[1:])
        if t.endswith("```"):
            t = t[:-3]
        return t.strip()

    def _render_ortho(
        self, scad_path: str, timestamp: str, tag: str
    ) -> Dict[str, str]:
        out_dir = os.path.join(self.image_dir, f"{timestamp}_{tag}")
        os.makedirs(out_dir, exist_ok=True)
        return self.renderer.render_all_views(
            scad_path,
            out_dir,
            prefix=tag,
            views=ORTHO_VIEW_NAMES,
        )

    def _call_analyze_vision(
        self,
        text_prompt: str,
        view_images: Dict[str, str],
        sketch_path: Optional[str],
        reference_images: Optional[Dict[str, Dict[str, str]]] = None,
        input_view_paths: Optional[List[str]] = None,
    ) -> str:
        if self.model in RESPONSES_API_VISION_MODELS:
            return self._responses_vision_json(
                text_prompt, view_images, sketch_path, reference_images,
                input_view_paths,
            )
        return self._chat_vision_json(
            text_prompt, view_images, sketch_path, reference_images,
            input_view_paths,
        )

    def _responses_vision_json(
        self,
        text_prompt: str,
        view_images: Dict[str, str],
        sketch_path: Optional[str],
        reference_images: Optional[Dict[str, Dict[str, str]]],
        input_view_paths: Optional[List[str]] = None,
    ) -> str:
        content_parts: List[Dict[str, Any]] = [
            {"type": "input_text", "text": text_prompt}
        ]
        # Image-only mode (Z2C 8-view eval): TARGET views come FIRST so the
        # model anchors on the spec before seeing the current model.
        if input_view_paths:
            content_parts.append(
                {
                    "type": "input_text",
                    "text": "\n\n=== TARGET REFERENCE VIEWS (this IS the spec) ===\n",
                }
            )
            for i, p in enumerate(input_view_paths):
                if os.path.exists(p):
                    content_parts.append(
                        {"type": "input_text", "text": f"\nTARGET VIEW {i}:"}
                    )
                    content_parts.append(
                        {
                            "type": "input_image",
                            "image_url": self._image_to_base64(p),
                        }
                    )
            content_parts.append(
                {"type": "input_text", "text": "\n=== CURRENT MODEL VIEWS ===\n"}
            )
        if sketch_path and os.path.exists(sketch_path):
            content_parts.append(
                {
                    "type": "input_text",
                    "text": "\n\n=== DESIGN INTENT SKETCH ===\n"
                    "Compare the renders below to this target silhouette/parts.",
                }
            )
            content_parts.append(
                {
                    "type": "input_image",
                    "image_url": self._image_to_base64(sketch_path),
                }
            )
        if reference_images:
            content_parts.append(
                {"type": "input_text", "text": "\n\n=== KB REFERENCE IMAGES ==="}
            )
            for comp_id, comp_ref in reference_images.items():
                content_parts.append(
                    {"type": "input_text", "text": f"\nComponent: {comp_id}"}
                )
                for vn, pth in comp_ref.items():
                    if os.path.exists(pth):
                        content_parts.append(
                            {"type": "input_text", "text": f"  {vn.upper()}:"}
                        )
                        content_parts.append(
                            {
                                "type": "input_image",
                                "image_url": self._image_to_base64(pth),
                            }
                        )
            content_parts.append(
                {"type": "input_text", "text": "\n=== CURRENT MODEL VIEWS ===\n"}
            )
        for vn in ORTHO_VIEW_NAMES:
            if vn in view_images and os.path.exists(view_images[vn]):
                content_parts.append(
                    {"type": "input_text", "text": f"\n{vn.upper()} VIEW:"}
                )
                content_parts.append(
                    {
                        "type": "input_image",
                        "image_url": self._image_to_base64(view_images[vn]),
                    }
                )

        response = self.client.responses.create(
            model=self.model,
            input=[{"role": "user", "content": content_parts}],
            temperature=0.1,
            max_output_tokens=2500,
            text={"format": {"type": "json_object"}},
        )
        return response.output_text

    def _chat_vision_json(
        self,
        text_prompt: str,
        view_images: Dict[str, str],
        sketch_path: Optional[str],
        reference_images: Optional[Dict[str, Dict[str, str]]],
        input_view_paths: Optional[List[str]] = None,
    ) -> str:
        content_parts: List[Dict[str, Any]] = [
            {"type": "text", "text": text_prompt}
        ]
        if input_view_paths:
            content_parts.append(
                {
                    "type": "text",
                    "text": "\n=== TARGET REFERENCE VIEWS (this IS the spec) ===\n",
                }
            )
            for i, p in enumerate(input_view_paths):
                if os.path.exists(p):
                    content_parts.append(
                        {"type": "text", "text": f"\nTARGET VIEW {i}:"}
                    )
                    content_parts.append(
                        {
                            "type": "image_url",
                            "image_url": {"url": self._image_to_base64(p)},
                        }
                    )
            content_parts.append(
                {"type": "text", "text": "\n=== CURRENT MODEL VIEWS ===\n"}
            )
        if sketch_path and os.path.exists(sketch_path):
            content_parts.append(
                {
                    "type": "text",
                    "text": "\n=== DESIGN INTENT SKETCH ===\n",
                }
            )
            content_parts.append(
                {
                    "type": "image_url",
                    "image_url": {"url": self._image_to_base64(sketch_path)},
                }
            )
        if reference_images:
            content_parts.append({"type": "text", "text": "\n=== KB REFERENCES ==="})
            for comp_id, comp_ref in reference_images.items():
                content_parts.append(
                    {"type": "text", "text": f"\nComponent: {comp_id}"}
                )
                for vn, pth in comp_ref.items():
                    if os.path.exists(pth):
                        content_parts.append(
                            {"type": "text", "text": f"  {vn.upper()}:"}
                        )
                        content_parts.append(
                            {
                                "type": "image_url",
                                "image_url": {"url": self._image_to_base64(pth)},
                            }
                        )
        for vn in ORTHO_VIEW_NAMES:
            if vn in view_images and os.path.exists(view_images[vn]):
                content_parts.append(
                    {"type": "text", "text": f"\n{vn.upper()} VIEW:"}
                )
                content_parts.append(
                    {
                        "type": "image_url",
                        "image_url": {"url": self._image_to_base64(view_images[vn])},
                    }
                )

        kwargs: Dict[str, Any] = {
            "model": self.model,
            "messages": [{"role": "user", "content": content_parts}],
            "temperature": 0.1,
            **self._get_token_param(2500),
            "response_format": {"type": "json_object"},
        }
        response = self.client.chat.completions.create(**kwargs)
        return response.choices[0].message.content or ""

    def _apply_gaps_text(self, current_code: str, original_prompt: str, gaps: List[Dict[str, Any]]) -> str:
        gaps_json = json.dumps(gaps, indent=2)
        user = APPLY_GAPS_PROMPT.format(
            original_prompt=original_prompt,
            gaps_json=gaps_json,
            current_code=current_code,
        )
        temperature = 0.0 if self.model not in REASONING_MODELS else 0.1
        kwargs = {
            "model": self.model,
            "messages": [
                {
                    "role": "system",
                    "content": "You output only valid OpenSCAD source code.",
                },
                {"role": "user", "content": user},
            ],
            "temperature": temperature,
            **self._get_token_param(8000),
        }
        response = self.client.chat.completions.create(**kwargs)
        raw = response.choices[0].message.content or ""
        return self._extract_scad(raw)

    def run(
        self,
        scad_code: str,
        scad_path: str,
        original_prompt: str,
        expected_parts: List[str],
        timestamp: str,
        sketch_path: Optional[str] = None,
        kb_reference_images: Optional[Dict[str, Dict[str, str]]] = None,
        input_view_paths: Optional[List[str]] = None,
    ) -> GapRefinementResult:
        """Render six views, analyze gaps, optionally apply one patch.

        Modes:
          - text mode (default): TARGET = original_prompt + optional sketch.
            Uses GAP_ANALYSIS_PROMPT.
          - image-only mode: `input_view_paths` provided (e.g. Z2C's 8 views).
            TARGET = those input views. Uses GAP_ANALYSIS_PROMPT_VIEWS and
            ignores `sketch_path` (the views ARE the spec).
        """
        try:
            view_images = self._render_ortho(scad_path, timestamp, "v3_baseline")
            if not view_images:
                return GapRefinementResult(
                    success=False,
                    final_code=scad_code,
                    applied_patch=False,
                    error="orthographic render failed",
                )

            if input_view_paths:
                # Image-only mode: views are the spec; ignore sketch path.
                text_prompt = GAP_ANALYSIS_PROMPT_VIEWS.format(
                    n_target_views=len(input_view_paths),
                )
                effective_sketch = None
            else:
                parts_line = (
                    ", ".join(expected_parts)
                    if expected_parts
                    else "(none specified)"
                )
                text_prompt = GAP_ANALYSIS_PROMPT.format(
                    original_prompt=original_prompt,
                    expected_parts=parts_line,
                )
                effective_sketch = sketch_path

            raw = self._call_analyze_vision(
                text_prompt,
                view_images,
                effective_sketch,
                kb_reference_images,
                input_view_paths,
            )
            analysis = self._extract_json(raw)
            if not analysis:
                return GapRefinementResult(
                    success=False,
                    final_code=scad_code,
                    applied_patch=False,
                    analysis={"parse_error": True, "raw": raw[:500]},
                    view_images=view_images,
                    error="gap analysis JSON parse failed",
                )

            gaps = analysis.get("gaps") or []
            no_change = bool(analysis.get("no_changes_needed"))
            if no_change or not gaps:
                return GapRefinementResult(
                    success=True,
                    final_code=scad_code,
                    applied_patch=False,
                    analysis=analysis,
                    view_images=view_images,
                )

            new_code = self._apply_gaps_text(scad_code, original_prompt, gaps)
            if not new_code or len(new_code) < 30:
                return GapRefinementResult(
                    success=False,
                    final_code=scad_code,
                    applied_patch=False,
                    analysis=analysis,
                    view_images=view_images,
                    error="apply step returned empty or trivial code",
                )

            with tempfile.NamedTemporaryFile(
                mode="w", suffix=".scad", delete=False, encoding="utf-8"
            ) as tmp:
                tmp.write(new_code)
                tmp_path = tmp.name
            try:
                after_views = self._render_ortho(tmp_path, timestamp, "v3_after")
            finally:
                if os.path.exists(tmp_path):
                    try:
                        os.remove(tmp_path)
                    except OSError:
                        pass

            final_views = after_views if after_views else view_images
            return GapRefinementResult(
                success=True,
                final_code=new_code,
                applied_patch=True,
                analysis=analysis,
                view_images=final_views,
            )
        except Exception as e:
            return GapRefinementResult(
                success=False,
                final_code=scad_code,
                applied_patch=False,
                error=f"{type(e).__name__}: {e}",
            )


__all__ = ["GapRefiner", "GapRefinementResult", "ORTHO_VIEW_NAMES"]
