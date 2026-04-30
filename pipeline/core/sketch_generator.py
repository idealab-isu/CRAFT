"""
CRAFT v2 Sketch Generator
=========================

Given a (possibly concretized) text prompt + geometric hints, produce a clean
orthographic technical sketch of the target object and return its file path.
The sketch serves two roles downstream:

1. *Planner grounding* — the planner sees the sketch (via vision modality)
   alongside the text, so it commits to a specific visual interpretation
   instead of hallucinating geometry from text alone.
2. *UI reference* — the sketch appears in the Output panel next to the
   generated model renders, giving the user a visual diff between "what
   CRAFT decided to draw" and "what CRAFT actually built."

The generator uses OpenAI's Images API (``gpt-image-1`` by default) and falls
back gracefully when the API is unavailable or the call errors — in that
case we return ``None`` and the pipeline just skips the sketch step.

Configuration (env vars):
  - ``CRAFT_SKETCH_ENABLED``   — "1" / "true" to turn on (default: "1")
  - ``CRAFT_SKETCH_MODE``      — ``plan`` | ``verify`` (default: ``verify``).
                                 ``plan`` = sketch before planning (vision input to planner).
                                 ``verify`` = sketch after CAD/render only, not fed to planner.
  - ``CRAFT_SKETCH_MODEL``     — image-gen model (default: "gpt-image-1")
  - ``CRAFT_SKETCH_SIZE``      — image size (default: "1024x1024")
  - ``CRAFT_SKETCH_DIR``       — cache dir (default: "static/sketches")

Output: a PNG on disk + metadata via :class:`SketchResult`.
"""

from __future__ import annotations

import base64
import os
from dataclasses import dataclass, field
from typing import Any, Dict, List, Optional


# --------------------------------------------------------------------------- #
# Config
# --------------------------------------------------------------------------- #

SKETCH_ENABLED_DEFAULT = os.getenv("CRAFT_SKETCH_ENABLED", "1").lower() in (
    "1", "true", "yes", "on",
)
# plan  = generate sketch before planning (legacy: planner sees the image)
# verify = generate sketch only after pipeline render (default: avoids misleading planner)
_raw_mode = os.getenv("CRAFT_SKETCH_MODE", "verify").strip().lower()
SKETCH_MODE_DEFAULT = _raw_mode if _raw_mode in ("plan", "verify") else "verify"
SKETCH_MODEL = os.getenv("CRAFT_SKETCH_MODEL", "gpt-image-1")
SKETCH_SIZE = os.getenv("CRAFT_SKETCH_SIZE", "1024x1024")
SKETCH_DIR = os.getenv("CRAFT_SKETCH_DIR", os.path.join("static", "sketches"))


_SKETCH_SYSTEM_INSTRUCTION = (
    "Draw a clean, minimalistic orthographic technical line sketch of the "
    "described object on a white background. Use thin black lines only — no "
    "shading, no color, no photorealism, no perspective distortion. Keep "
    "proportions realistic. Show the front or three-quarter view that most "
    "clearly reveals all canonical parts of the object. If helpful, label "
    "key dimensions in millimeters with small arrows, but keep labels sparse. "
    "The sketch should look like a designer's concept drawing, suitable as a "
    "reference for a parametric CAD model."
)


# --------------------------------------------------------------------------- #
# Result dataclass
# --------------------------------------------------------------------------- #

@dataclass
class SketchResult:
    """Outcome of a sketch-generation attempt."""
    success: bool
    image_path: Optional[str] = None
    web_path: Optional[str] = None          # relative path under /static
    prompt_used: Optional[str] = None
    model: Optional[str] = None
    size: Optional[str] = None
    error: Optional[str] = None
    notes: List[str] = field(default_factory=list)

    def to_dict(self) -> Dict[str, Any]:
        return {
            "success": self.success,
            "image_path": self.image_path,
            "web_path": self.web_path,
            "prompt_used": self.prompt_used,
            "model": self.model,
            "size": self.size,
            "error": self.error,
            "notes": list(self.notes),
        }


# --------------------------------------------------------------------------- #
# Sketch prompt assembly
# --------------------------------------------------------------------------- #

def _proportional_hint_for(category: str, value_mm: float) -> Optional[str]:
    """Render a one-liner description of canonical proportions for
    ``category`` at total size ``value_mm``. Returns None when we have no
    hint for that category."""
    v = float(value_mm)
    if category == "car":
        return (
            f"Total length {v:.0f}mm; wheel diameter ≈ {v/7:.0f}mm; "
            f"cabin ≈ {v*0.45:.0f}mm long, ≈ {v*0.22:.0f}mm tall; "
            f"body height ≈ {v*0.30:.0f}mm; ground clearance ≈ {v*0.05:.0f}mm; "
            f"windows short relative to body."
        )
    if category == "watch":
        return (
            f"Case diameter {v:.0f}mm; case thickness ≈ {v*0.30:.0f}mm; "
            f"bezel width ≈ {v*0.08:.0f}mm; crown ≈ {v*0.14:.0f}mm across, "
            f"sticking out on the right; lugs ≈ {v*0.20:.0f}mm long."
        )
    if category == "chair":
        return (
            f"Seat width {v:.0f}mm, seat depth ≈ {v:.0f}mm; legs thin "
            f"(~{v*0.10:.0f}mm cross-section); back ≈ {v:.0f}mm tall."
        )
    if category == "mug":
        return (
            f"Outer diameter {v:.0f}mm, height ≈ {v*1.1:.0f}mm, wall thin "
            f"(~{v*0.08:.0f}mm), handle loop ≈ {v*0.4:.0f}mm wide."
        )
    if category == "bottle":
        return (
            f"Total height {v:.0f}mm; body diameter ≈ {v*0.30:.0f}mm; "
            f"neck ≈ {v*0.10:.0f}mm diameter, ≈ {v*0.12:.0f}mm tall; "
            f"cap just above the neck."
        )
    if category == "phone":
        return (
            f"Length {v:.0f}mm, width ≈ {v*0.48:.0f}mm, very thin "
            f"(~{v*0.035:.0f}mm); screen covers most of the front."
        )
    if category == "gear":
        return (
            f"Outer diameter {v:.0f}mm; teeth short (~{v*0.07:.0f}mm); "
            f"central bore ≈ {v*0.20:.0f}mm."
        )
    if category == "fan":
        return (
            f"Outer diameter {v:.0f}mm; blades span from hub to rim; "
            f"hub ≈ {v*0.30:.0f}mm across."
        )
    return None


def build_sketch_prompt(
    description: str,
    parts: Optional[List[str]] = None,
    dimensions: Optional[Dict[str, Any]] = None,
    extra_notes: Optional[List[str]] = None,
    primary_dimension: Optional[Dict[str, Any]] = None,
) -> str:
    """Compose the image-gen prompt from the refined design brief.

    We keep it short and explicit — long prompts make the image model drift
    into "artistic" territory and lose the orthographic discipline we want.
    """
    lines: List[str] = [_SKETCH_SYSTEM_INSTRUCTION, "", f"OBJECT: {description}"]

    if parts:
        clean = [str(p).strip() for p in parts if str(p).strip()][:8]
        if clean:
            lines.append("REQUIRED PARTS (must be visible in the sketch): "
                         + ", ".join(clean))

    # When the user specified a total size, push it to the top of the
    # prompt as a PROPORTIONAL CONSTRAINT block. The image model tends to
    # latch onto the largest, most concrete number, so we surface the
    # primary dimension prominently and derive canonical ratios when we
    # recognize the category.
    if primary_dimension and isinstance(primary_dimension, dict):
        label = primary_dimension.get("label", "primary dimension")
        value_mm = primary_dimension.get("value_mm")
        category = primary_dimension.get("category", "generic")
        if value_mm:
            try:
                value_num = float(value_mm)
                hint = _proportional_hint_for(category, value_num)
                lines.append(
                    f"PROPORTIONAL CONSTRAINTS — {label} = {value_num:.0f}mm "
                    f"(category: {category})."
                )
                if hint:
                    lines.append(f"Size cues: {hint}")
                lines.append(
                    "All other parts of the sketch must scale consistently "
                    "with this total size — no exaggerated wheels, handles, "
                    "or details."
                )
            except (TypeError, ValueError):
                pass

    if dimensions:
        dim_bits = []
        for k, v in dimensions.items():
            dim_bits.append(f"{k}≈{v}mm")
            if len(dim_bits) >= 6:
                break
        if dim_bits:
            lines.append("APPROX DIMENSIONS: " + ", ".join(dim_bits))

    if extra_notes:
        for n in extra_notes[:3]:
            n = str(n).strip()
            if n:
                lines.append(f"NOTE: {n}")

    lines.append("")
    lines.append(
        "Keep the final image below 1024x1024, clean white background, no "
        "text outside the dimension labels, no watermark."
    )
    return "\n".join(lines)


# --------------------------------------------------------------------------- #
# Sketch generator
# --------------------------------------------------------------------------- #

class SketchGenerator:
    """Thin wrapper around an OpenAI-compatible Images API client."""

    def __init__(
        self,
        client: Any,
        model: str = SKETCH_MODEL,
        size: str = SKETCH_SIZE,
        output_dir: str = SKETCH_DIR,
        enabled: bool = SKETCH_ENABLED_DEFAULT,
    ):
        self.client = client
        self.model = model
        self.size = size
        self.output_dir = output_dir
        self.enabled = enabled
        try:
            os.makedirs(self.output_dir, exist_ok=True)
        except OSError as e:
            print(f"[SketchGen] Could not create cache dir {self.output_dir}: {e}")

    # ------------------------------------------------------------------ #
    # Public API
    # ------------------------------------------------------------------ #

    def generate(
        self,
        description: str,
        timestamp: str,
        parts: Optional[List[str]] = None,
        dimensions: Optional[Dict[str, Any]] = None,
        extra_notes: Optional[List[str]] = None,
        primary_dimension: Optional[Dict[str, Any]] = None,
    ) -> SketchResult:
        """Synthesize a sketch PNG for ``description`` and write it to disk."""
        if not self.enabled:
            return SketchResult(
                success=False,
                error="disabled via CRAFT_SKETCH_ENABLED",
                notes=["SketchGenerator disabled"],
            )

        prompt = build_sketch_prompt(
            description=description,
            parts=parts,
            dimensions=dimensions,
            extra_notes=extra_notes,
            primary_dimension=primary_dimension,
        )

        try:
            image_b64 = self._call_image_api(prompt)
        except Exception as e:
            msg = f"{type(e).__name__}: {str(e)[:200]}"
            print(f"[SketchGen] Image API call failed: {msg}")
            return SketchResult(
                success=False,
                prompt_used=prompt,
                model=self.model,
                size=self.size,
                error=msg,
            )

        if not image_b64:
            return SketchResult(
                success=False,
                prompt_used=prompt,
                model=self.model,
                size=self.size,
                error="empty image response",
            )

        filename = f"sketch_{timestamp}.png"
        path = os.path.join(self.output_dir, filename)
        try:
            with open(path, "wb") as f:
                f.write(base64.b64decode(image_b64))
        except OSError as e:
            return SketchResult(
                success=False,
                prompt_used=prompt,
                model=self.model,
                size=self.size,
                error=f"failed to write sketch: {e}",
            )

        # Derive a web path if the output_dir lives under static/
        web_path: Optional[str] = None
        norm = path.replace("\\", "/")
        if "static/" in norm:
            web_path = norm[norm.index("static/"):]

        print(f"[SketchGen] Sketch written to {path}")
        return SketchResult(
            success=True,
            image_path=path,
            web_path=web_path,
            prompt_used=prompt,
            model=self.model,
            size=self.size,
            notes=[
                f"Sketch generated with {self.model} at {self.size}",
            ],
        )

    # ------------------------------------------------------------------ #
    # Internals
    # ------------------------------------------------------------------ #

    def _call_image_api(self, prompt: str) -> Optional[str]:
        """Call the OpenAI-compatible Images API and return base64 PNG data."""
        # The OpenAI Python SDK exposes ``client.images.generate(...)`` — we
        # request ``response_format="b64_json"`` so we get the raw bytes back
        # without a second HTTP hop. Newer models (``gpt-image-1``) always
        # return b64_json regardless, but we ask explicitly for safety.
        kwargs: Dict[str, Any] = {
            "model": self.model,
            "prompt": prompt,
            "size": self.size,
            "n": 1,
        }
        # gpt-image-1 doesn't accept response_format; DALL-E does.
        if not self.model.startswith("gpt-image"):
            kwargs["response_format"] = "b64_json"

        resp = self.client.images.generate(**kwargs)
        data = getattr(resp, "data", None)
        if not data:
            return None
        first = data[0]
        b64 = getattr(first, "b64_json", None)
        if b64:
            return b64
        # Some SDKs return {url: ...} — we don't follow URLs here, the caller
        # can re-enable that if needed.
        return None


# --------------------------------------------------------------------------- #
# Convenience helper
# --------------------------------------------------------------------------- #

def sketch_from_design_brief(
    client: Any,
    brief: Any,
    timestamp: str,
    enhanced_prompt: Optional[str] = None,
    enabled: bool = SKETCH_ENABLED_DEFAULT,
    *,
    for_post_render_verification: bool = False,
) -> SketchResult:
    """Generate a sketch given a :class:`DesignBrief`.

    Pulls description, essential parts, and acceptance-criteria dimensions
    out of the brief so the caller doesn't have to duplicate that logic.
    ``enhanced_prompt`` overrides ``brief.description`` when given.
    """
    description = (enhanced_prompt or getattr(brief, "description", "") or "").strip()
    if not description:
        return SketchResult(
            success=False,
            error="no description available for sketch",
            notes=["Skipping sketch — DesignBrief.description is empty"],
        )

    parts = (
        list(getattr(brief, "essential_parts", []) or [])
        or list(getattr(brief, "expected_parts", []) or [])
    )

    dimensions: Dict[str, Any] = {}
    params = getattr(brief, "parameters", {}) or {}
    if isinstance(params, dict):
        for k, v in params.items():
            if isinstance(v, (int, float)) and v > 0:
                dimensions[k] = v
            if len(dimensions) >= 6:
                break

    extra_notes: List[str] = []
    if for_post_render_verification:
        extra_notes.append(
            "VERIFICATION REFERENCE (not for design exploration): include every part "
            "named above; proportions should match the stated dimensions so a reviewer "
            "can compare this drawing to a finished CAD render for completeness."
        )
    ac = getattr(brief, "acceptance_criteria", None)
    if ac is not None:
        ac_notes = getattr(ac, "notes", None) or []
        # ``notes`` is a single string in AcceptanceCriteria, but older briefs
        # sometimes carried a list; accept both forms defensively.
        if isinstance(ac_notes, str):
            if ac_notes.strip():
                extra_notes.append(ac_notes.strip())
        else:
            extra_notes.extend([str(n) for n in list(ac_notes)[:2]])

    primary_dimension = getattr(brief, "primary_dimension", None)

    gen = SketchGenerator(client=client, enabled=enabled)
    return gen.generate(
        description=description,
        timestamp=timestamp,
        parts=parts,
        dimensions=dimensions,
        extra_notes=extra_notes,
        primary_dimension=primary_dimension,
    )


__all__ = [
    "SKETCH_ENABLED_DEFAULT",
    "SKETCH_MODE_DEFAULT",
    "SKETCH_MODEL",
    "SKETCH_SIZE",
    "SKETCH_DIR",
    "SketchResult",
    "SketchGenerator",
    "build_sketch_prompt",
    "sketch_from_design_brief",
]
