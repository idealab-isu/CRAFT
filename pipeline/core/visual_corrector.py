"""
CRAFT Visual Self-Corrector

This module provides VLM-based self-correction for generated OpenSCAD code.

The process:
1. Render 6 orthographic views (front, back, left, right, top, bottom)
2. Send all 6 images + original prompt to VLM
3. VLM assesses if the model matches the intent and suggests corrections
4. If corrections needed, LLM generates fixed SCAD code
5. Repeat up to MAX_ITERATIONS times

This replaces the deterministic validation + repair loop with a visual feedback loop.
"""

import os
import base64
import json
import re
import time
import tempfile
from typing import Dict, Any, Optional, List, Tuple
from dataclasses import dataclass, field, asdict
from datetime import datetime

from utils.openscad_runner import OpenScadRunner, RenderMode
from utils.rendering import STANDARD_VIEWS, ORTHO_VIEWS, MultiViewRenderer
from core.validator import Validator, ValidationResult, check_syntax, check_renders_non_blank
from core.scad_autofix import SCADAutoFixer


# =============================================================================
# CONFIGURATION
# =============================================================================

MAX_VLM_ITERATIONS = int(os.getenv("MAX_VLM_ITERATIONS", "3"))
ORTHO_VIEW_NAMES = ["front", "back", "left", "right", "top", "bottom"]

# Early stopping confidence threshold (0.95 = 95%)
CONFIDENCE_THRESHOLD = float(os.getenv("VLM_CONFIDENCE_THRESHOLD", "0.95"))

# Models that use max_completion_tokens instead of max_tokens
NEW_API_MODELS = {"gpt-5.1", "gpt-5.2", "o1", "o1-mini", "o1-preview", "o3", "o3-mini"}

# Models that require Responses API for vision (input_image format)
RESPONSES_API_VISION_MODELS = {"gpt-5.2"}

# Reasoning models that need concise, outcome-focused prompts (not step-by-step)
REASONING_MODELS = {"gpt-5.2", "o1", "o1-mini", "o1-preview", "o3", "o3-mini"}

# Retry configuration
MAX_API_RETRIES = 3
RETRY_DELAY_BASE = 2  # Base delay in seconds for exponential backoff


# =============================================================================
# OPTIMIZED PROMPTS FOR REASONING MODELS
# =============================================================================

# Concise assessment prompt for reasoning models (GPT-5.2)
# Let the model reason internally without step-by-step instructions
REASONING_MODEL_ASSESS_PROMPT = """Evaluate if this 3D CAD model matches the request.

REQUEST: {original_prompt}

The 6 images show orthographic views (front, back, left, right, top, bottom).

CRITICAL: If the images appear BLANK, EMPTY, or show NO visible 3D object, you MUST:
- Set "approved": false
- Set "confidence": 0.0
- Set "overall_match": "poor"
- Add "Images appear blank or empty - no visible geometry" to issues

Respond with JSON:
{{
    "approved": true/false,
    "confidence": 0.0-1.0,
    "overall_match": "good" | "partial" | "poor",
    "issues": ["significant issues only"],
    "suggestions": ["prioritized fixes"],
    "view_assessments": {{"front": "...", "back": "...", ...}}
}}

Approve if the essential parts are recognizable. Be lenient on details but NEVER approve empty renders."""

# Concise fix prompt for reasoning models (GPT-5.2)
REASONING_MODEL_FIX_PROMPT = """Fix this OpenSCAD code to match: {original_prompt}

Issues found:
{issues}

**CONNECTIVITY FIX EXAMPLES:**

WRONG - Parts floating:
```
body_h = 30;
attachment_h = 20;
union() {{
    cube([40, 40, body_h], center=true);           // body
    translate([0, 0, 50]) cylinder(h=attachment_h); // WRONG: 50 is arbitrary, attachment floats!
}}
```

CORRECT - Parts connected:
```
body_h = 30;
attachment_h = 20;
union() {{
    cube([40, 40, body_h], center=true);                              // body
    translate([0, 0, body_h/2 + attachment_h/2 - 1])                  // CORRECT: calculated from dimensions
        cylinder(h=attachment_h, r=10, center=true);                   // -1 creates overlap
}}
```

WRONG - Side attachment floating:
```
main_w = 60;
side_w = 20;
union() {{
    cube([main_w, 40, 30], center=true);
    translate([80, 0, 0]) cube([side_w, 20, 20], center=true);  // WRONG: 80 > 60, floats away!
}}
```

CORRECT - Side attachment connected:
```
main_w = 60;
side_w = 20;
union() {{
    cube([main_w, 40, 30], center=true);
    translate([main_w/2 + side_w/2 - 1, 0, 0])                  // CORRECT: 30 + 10 - 1 = 39
        cube([side_w, 20, 20], center=true);
}}
```

RADIAL ARRAY - Teeth that PROTRUDE OUTWARD (gears, fans):
```
overlap = 2;  // Tooth overlaps INTO hub by this amount
union() {{
    cylinder(r=hub_r, h=hub_h, center=true);
    for (i = [0:num_teeth-1])
        rotate([0, 0, i * 360/num_teeth])
            // Inner edge at hub_r - overlap (INSIDE hub), outer edge protrudes OUT
            translate([hub_r + tooth_len/2 - overlap, 0, 0])
                cube([tooth_len, tooth_w, hub_h], center=true);
}}
```

LOOP HANDLE - Must connect at TWO points (for mugs, cups):
```
union() {{
    cylinder(r=body_r, h=body_h, center=true);
    translate([body_r - 2, 0, 0])
        hull() {{
            translate([12, 0, 15]) sphere(r=4);
            translate([12, 0, -15]) sphere(r=4);
            translate([0, 0, 15]) sphere(r=4);
            translate([0, 0, -15]) sphere(r=4);
        }}
}}
```

HOLLOW CONTAINER - Use difference (for cups, boxes):
```
difference() {{
    cylinder(r=40, h=60, center=true);
    translate([0, 0, 3]) cylinder(r=37, h=60, center=true);  // Inner void
}}
```

**RULES:**
- translate() values = FORMULAS from dimensions, NOT arbitrary numbers
- Radial: rotate + translate([radius-1, 0, 0]) to place AT edge
- Handles: must LOOP back (hull or rotate_extrude), not single peg
- Hollow: use difference() with inner shape slightly smaller

Current code:
```openscad
{current_code}
```

Output ONLY corrected OpenSCAD code. Ensure model is ONE connected solid. Never add text/labels."""

# Auto-fix configuration for render timeouts
INITIAL_RENDER_TIMEOUT = int(os.getenv("INITIAL_RENDER_TIMEOUT", "60"))  # 60s for first attempt
EXTENDED_RENDER_TIMEOUT = int(os.getenv("EXTENDED_RENDER_TIMEOUT", "120"))  # 120s after auto-fix
MAX_AUTOFIX_ATTEMPTS = int(os.getenv("MAX_AUTOFIX_ATTEMPTS", "2"))  # Max auto-fix retries


# =============================================================================
# DATA CLASSES
# =============================================================================

@dataclass
class VLMAssessment:
    """Result of VLM visual assessment."""
    iteration: int
    approved: bool
    confidence: float  # 0-1
    issues: List[str]
    suggestions: List[str]
    overall_match: str  # "good", "partial", "poor"
    view_assessments: Dict[str, str]  # per-view feedback


@dataclass
class CorrectionResult:
    """Result of a single correction iteration."""
    iteration: int
    scad_code: str
    view_images: Dict[str, str]  # view_name -> image_path
    deterministic_passed: bool
    deterministic_score: int
    vlm_assessment: Optional[VLMAssessment]
    corrected: bool  # whether correction was applied this iteration


@dataclass
class VisualCorrectionResult:
    """Final result of the visual correction loop."""
    success: bool
    final_code: str
    iterations: int
    final_score: int
    final_passed: bool
    iteration_history: List[CorrectionResult]
    final_view_images: Dict[str, str]
    final_assessment: Optional[VLMAssessment]


# =============================================================================
# VISUAL SELF-CORRECTOR
# =============================================================================

class VisualSelfCorrector:
    """
    VLM-based self-correction loop for OpenSCAD code.

    Renders multiple views, uses VLM to assess, and iteratively corrects.
    """

    def __init__(
        self,
        client,
        model: str,
        max_iterations: int = MAX_VLM_ITERATIONS,
        image_dir: str = "static/images",
        pass_threshold: float = 0.80
    ):
        """
        Initialize the visual corrector.

        Args:
            client: Unified LLM client (supports vision)
            model: Model to use for VLM assessment and correction
            max_iterations: Maximum correction iterations
            image_dir: Directory to save view images
            pass_threshold: Deterministic validation threshold
        """
        self.client = client
        self.model = model
        self.max_iterations = max_iterations
        self.image_dir = image_dir
        self.pass_threshold = pass_threshold

        # Multi-view renderer with initial shorter timeout
        # We start with a shorter timeout and extend after auto-fix if needed
        self.renderer = MultiViewRenderer(
            imgsize=(400, 400),
            distance=200,
            timeout=INITIAL_RENDER_TIMEOUT  # Start with 60s, extend if auto-fix applied
        )

        # Extended timeout renderer (used after auto-fix)
        self.extended_renderer = MultiViewRenderer(
            imgsize=(400, 400),
            distance=200,
            timeout=EXTENDED_RENDER_TIMEOUT  # 120s after auto-fix
        )

        # Deterministic validator (for basic checks)
        self.validator = Validator(pass_threshold)

        # SCAD auto-fixer for handling render timeouts
        self.auto_fixer = SCADAutoFixer(client, model)

    def _get_token_param(self, max_tokens: int) -> Dict[str, int]:
        """
        Get the correct token limit parameter based on model.

        Newer models (gpt-5.x, o1, o3) use max_completion_tokens.
        Older models (gpt-4o) use max_tokens.
        """
        if self.model in NEW_API_MODELS:
            return {"max_completion_tokens": max_tokens}
        return {"max_tokens": max_tokens}

    def _call_vision_api(
        self,
        text_prompt: str,
        view_images: Dict[str, str],
        view_names: List[str],
        max_tokens: int,
        temperature: float,
        json_response: bool,
        reference_images: Dict[str, Dict[str, str]] = None
    ) -> str:
        """
        Call the appropriate vision API based on model.

        - GPT-5.2: Uses Responses API with input_image format
        - GPT-4o/GPT-5.1: Uses Chat Completions API with image_url format

        Includes retry logic with exponential backoff.
        
        Args:
            reference_images: Optional dict of {component_id: {view_name: image_path}}
        """
        last_error = None

        for attempt in range(MAX_API_RETRIES + 1):
            try:
                if self.model in RESPONSES_API_VISION_MODELS:
                    return self._call_responses_api(
                        text_prompt, view_images, view_names,
                        max_tokens, temperature, json_response,
                        reference_images=reference_images
                    )
                else:
                    return self._call_chat_completions_api(
                        text_prompt, view_images, view_names,
                        max_tokens, temperature, json_response,
                        reference_images=reference_images
                    )
            except Exception as e:
                last_error = e
                error_str = str(e).lower()

                # Don't retry for certain errors (auth, invalid input)
                if "invalid" in error_str or "unauthorized" in error_str or "api key" in error_str:
                    raise e

                if attempt < MAX_API_RETRIES:
                    delay = RETRY_DELAY_BASE ** attempt
                    print(f"[VLM] API call failed (attempt {attempt + 1}), retrying in {delay}s: {e}")
                    time.sleep(delay)
                else:
                    raise last_error

        raise last_error

    def _call_responses_api(
        self,
        text_prompt: str,
        view_images: Dict[str, str],
        view_names: List[str],
        max_tokens: int,
        temperature: float,
        json_response: bool,
        reference_images: Dict[str, Dict[str, str]] = None
    ) -> str:
        """
        Call OpenAI Responses API for GPT-5.2 vision.

        Uses input_image format instead of image_url.
        """
        content_parts = []

        # Add text prompt using input_text format
        content_parts.append({
            "type": "input_text",
            "text": text_prompt
        })

        # Add KB reference images first (if available)
        if reference_images:
            content_parts.append({
                "type": "input_text",
                "text": "\n\n=== KNOWLEDGE BASE REFERENCE IMAGES ==="
            })
            for comp_id, comp_ref_images in reference_images.items():
                content_parts.append({
                    "type": "input_text",
                    "text": f"\nReference for component: {comp_id}"
                })
                for view_name, ref_image_path in comp_ref_images.items():
                    if os.path.exists(ref_image_path):
                        content_parts.append({
                            "type": "input_text",
                            "text": f"  {view_name.upper()} REFERENCE:"
                        })
                        content_parts.append({
                            "type": "input_image",
                            "image_url": self._image_to_base64(ref_image_path)
                        })
            content_parts.append({
                "type": "input_text",
                "text": "\n=== GENERATED MODEL VIEWS ===\n"
            })

        # Add view images with labels using input_image format
        for view_name in view_names:
            if view_name in view_images:
                image_path = view_images[view_name]
                if os.path.exists(image_path):
                    # Add label
                    content_parts.append({
                        "type": "input_text",
                        "text": f"\n{view_name.upper()} VIEW:"
                    })
                    # Add image using input_image format
                    content_parts.append({
                        "type": "input_image",
                        "image_url": self._image_to_base64(image_path)
                    })

        # Build kwargs for Responses API
        kwargs = {}
        if json_response:
            # For Responses API, use text format with JSON instruction
            kwargs["text"] = {"format": {"type": "json_object"}}

        response = self.client.responses.create(
            model=self.model,
            input=[{"role": "user", "content": content_parts}],
            temperature=temperature,
            max_output_tokens=max_tokens,
            **kwargs
        )

        return response.output_text

    def _call_chat_completions_api(
        self,
        text_prompt: str,
        view_images: Dict[str, str],
        view_names: List[str],
        max_tokens: int,
        temperature: float,
        json_response: bool,
        reference_images: Dict[str, Dict[str, str]] = None
    ) -> str:
        """
        Call OpenAI Chat Completions API for GPT-4o/GPT-5.1 vision.

        Uses image_url format.
        """
        content_parts = []

        # Add text prompt
        content_parts.append({
            "type": "text",
            "text": text_prompt
        })

        # Add KB reference images first (if available)
        if reference_images:
            content_parts.append({
                "type": "text",
                "text": "\n\n=== KNOWLEDGE BASE REFERENCE IMAGES ==="
            })
            for comp_id, comp_ref_images in reference_images.items():
                content_parts.append({
                    "type": "text",
                    "text": f"\nReference for component: {comp_id}"
                })
                for view_name, ref_image_path in comp_ref_images.items():
                    if os.path.exists(ref_image_path):
                        content_parts.append({
                            "type": "text",
                            "text": f"  {view_name.upper()} REFERENCE:"
                        })
                        content_parts.append({
                            "type": "image_url",
                            "image_url": {
                                "url": self._image_to_base64(ref_image_path)
                            }
                        })
            content_parts.append({
                "type": "text",
                "text": "\n=== GENERATED MODEL VIEWS ===\n"
            })

        # Add view images with labels
        for view_name in view_names:
            if view_name in view_images:
                image_path = view_images[view_name]
                if os.path.exists(image_path):
                    content_parts.append({
                        "type": "text",
                        "text": f"\n{view_name.upper()} VIEW:"
                    })
                    content_parts.append({
                        "type": "image_url",
                        "image_url": {
                            "url": self._image_to_base64(image_path)
                        }
                    })

        kwargs = {
            "model": self.model,
            "messages": [{"role": "user", "content": content_parts}],
            "temperature": temperature,
            **self._get_token_param(max_tokens)
        }

        if json_response:
            kwargs["response_format"] = {"type": "json_object"}

        response = self.client.chat.completions.create(**kwargs)
        return response.choices[0].message.content

    def run_correction_loop(
        self,
        scad_code: str,
        original_prompt: str,
        expected_parts: List[str],
        scad_path: str,
        timestamp: str,
        kb_components: List[Any] = None
    ) -> VisualCorrectionResult:
        """
        Run the full visual correction loop.

        Args:
            scad_code: Initial OpenSCAD code
            original_prompt: User's original prompt
            expected_parts: Expected component names
            scad_path: Path to SCAD file
            timestamp: Timestamp for file naming
            kb_components: Optional list of KBComponentContext objects for reference images

        Returns:
            VisualCorrectionResult with final code and history
        """
        iteration_history = []
        current_code = scad_code
        current_scad_path = scad_path

        for iteration in range(1, self.max_iterations + 1):
            print(f"[VLM Correction] Iteration {iteration}/{self.max_iterations}")

            # Step 1: Save current code
            with open(current_scad_path, "w", encoding="utf-8") as f:
                f.write(current_code)

            # Step 2: Render 6 orthographic views
            view_dir = os.path.join(self.image_dir, f"{timestamp}_iter{iteration}")
            os.makedirs(view_dir, exist_ok=True)

            view_images, render_timed_out = self._render_views_with_timeout_detection(
                current_scad_path, view_dir, timestamp, iteration
            )

            if not view_images:
                print(f"[VLM Correction] Render failed on iteration {iteration}")

                # If render timed out, try auto-fix
                if render_timed_out:
                    print(f"[VLM Correction] Render timeout detected, attempting auto-fix...")
                    fixed_code = self._attempt_autofix(
                        current_code, original_prompt, timeout_occurred=True
                    )

                    if fixed_code and fixed_code.strip() != current_code.strip():
                        print(f"[VLM Correction] Auto-fix applied, retrying render with extended timeout...")
                        current_code = fixed_code

                        # Save the fixed code
                        with open(current_scad_path, "w", encoding="utf-8") as f:
                            f.write(current_code)

                        # Retry render with extended timeout
                        view_images = self._render_views_extended(
                            current_scad_path, view_dir, timestamp, iteration
                        )

                        if view_images:
                            print(f"[VLM Correction] Render succeeded after auto-fix!")
                        else:
                            print(f"[VLM Correction] Render still failed after auto-fix")
                            # Try one more auto-fix iteration
                            fixed_code_2 = self._attempt_autofix(
                                current_code, original_prompt, timeout_occurred=True
                            )
                            if fixed_code_2 and fixed_code_2.strip() != current_code.strip():
                                current_code = fixed_code_2
                                with open(current_scad_path, "w", encoding="utf-8") as f:
                                    f.write(current_code)
                                view_images = self._render_views_extended(
                                    current_scad_path, view_dir, timestamp, iteration
                                )
                                if view_images:
                                    print(f"[VLM Correction] Render succeeded after second auto-fix!")
                    else:
                        print(f"[VLM Correction] Auto-fix did not produce different code")
                else:
                    # Non-timeout failure - try basic syntax fix
                    if iteration == 1:
                        current_code = self._attempt_syntax_fix(current_code, original_prompt)
                        continue

                # If still no view_images after all attempts, break
                if not view_images:
                    print(f"[VLM Correction] Unable to render after all fix attempts, breaking loop")
                    break

            # Step 3: Run deterministic checks (fast pre-filter)
            # Use the first rendered view for basic render check
            first_view_path = list(view_images.values())[0] if view_images else None
            det_result = self.validator.validate(
                current_code,
                expected_parts,
                original_prompt,
                current_scad_path,
                first_view_path
            )

            # Step 3.5: Check for blank renders BEFORE VLM assessment
            # If most renders are blank, VLM assessment should fail regardless of what VLM says
            blank_render_issues = []
            non_blank_count = 0
            for view_name, view_path in view_images.items():
                render_check = check_renders_non_blank(view_path)
                if not render_check.passed:
                    blank_render_issues.append(f"{view_name}: {render_check.message}")
                else:
                    non_blank_count += 1

            renders_are_blank = non_blank_count < 2  # At least 2 views must show something
            if renders_are_blank:
                print(f"[VLM Correction] WARNING: Most renders appear blank ({non_blank_count}/6 non-blank)")
                for issue in blank_render_issues[:3]:  # Show first 3 issues
                    print(f"  - {issue}")

            # Step 4: VLM assessment (send all 6 images + KB reference images)
            vlm_assessment = self._vlm_assess(
                view_images,
                original_prompt,
                current_code,
                iteration,
                kb_components=kb_components
            )

            # Step 4.5: Override VLM assessment if renders are blank
            # VLM may hallucinate approval for blank images - we must catch this
            if renders_are_blank and vlm_assessment:
                print(f"[VLM Correction] Overriding VLM approval due to blank renders")
                vlm_assessment.approved = False
                vlm_assessment.confidence = min(vlm_assessment.confidence, 0.3)  # Cap at 30%
                vlm_assessment.overall_match = "poor"
                vlm_assessment.issues = ["CRITICAL: Rendered images appear blank or empty - no visible 3D geometry"] + vlm_assessment.issues
                vlm_assessment.suggestions = ["Check OpenSCAD code for errors causing empty renders", "Simplify geometry to ensure it renders"] + vlm_assessment.suggestions

            # Record iteration result
            correction_result = CorrectionResult(
                iteration=iteration,
                scad_code=current_code,
                view_images=view_images,
                deterministic_passed=det_result.passed,
                deterministic_score=det_result.score,
                vlm_assessment=vlm_assessment,
                corrected=False
            )

            # Step 5: Check if we should stop (smarter early stopping)
            # Stop if:
            # 1. VLM approved explicitly
            # 2. Confidence >= 95%
            # 3. Overall match is "good" AND confidence >= 85% (essential parts OK)
            should_stop = False
            if vlm_assessment:
                if vlm_assessment.approved:
                    print(f"[VLM Correction] VLM approved on iteration {iteration}")
                    should_stop = True
                elif vlm_assessment.confidence >= CONFIDENCE_THRESHOLD:
                    print(f"[VLM Correction] High confidence ({vlm_assessment.confidence:.0%}) on iteration {iteration}, stopping early")
                    should_stop = True
                elif vlm_assessment.overall_match == "good" and vlm_assessment.confidence >= 0.85:
                    # Essential parts are good, minor issues with secondary/optional
                    print(f"[VLM Correction] Essential parts confirmed ({vlm_assessment.confidence:.0%}) on iteration {iteration}, stopping early")
                    should_stop = True
                    vlm_assessment.approved = True  # Mark as approved since essential parts are OK

            if should_stop:
                iteration_history.append(correction_result)
                return VisualCorrectionResult(
                    success=True,
                    final_code=current_code,
                    iterations=iteration,
                    final_score=det_result.score,
                    final_passed=True,
                    iteration_history=iteration_history,
                    final_view_images=view_images,
                    final_assessment=vlm_assessment
                )

            # Step 6: If not approved and below confidence threshold, attempt correction
            if iteration < self.max_iterations:
                print(f"[VLM Correction] Attempting correction based on {len(vlm_assessment.issues)} issues...")
                corrected_code = self._vlm_correct(
                    current_code,
                    original_prompt,
                    view_images,
                    vlm_assessment,
                    det_result
                )

                if corrected_code and corrected_code.strip() != current_code.strip():
                    correction_result.corrected = True
                    current_code = corrected_code
                    # Save the corrected code immediately so next iteration renders it
                    with open(current_scad_path, "w", encoding="utf-8") as f:
                        f.write(current_code)
                    print(f"[VLM Correction] Code corrected and saved on iteration {iteration} ({len(corrected_code)} chars)")
                else:
                    if corrected_code is None:
                        print(f"[VLM Correction] Correction returned None on iteration {iteration}")
                    else:
                        print(f"[VLM Correction] Correction returned same code on iteration {iteration}")

            iteration_history.append(correction_result)

        # Reached max iterations
        final_view_images = iteration_history[-1].view_images if iteration_history else {}
        final_assessment = iteration_history[-1].vlm_assessment if iteration_history else None
        final_score = iteration_history[-1].deterministic_score if iteration_history else 0

        return VisualCorrectionResult(
            success=final_assessment.approved if final_assessment else False,
            final_code=current_code,
            iterations=len(iteration_history),
            final_score=final_score,
            final_passed=final_assessment.approved if final_assessment else False,
            iteration_history=iteration_history,
            final_view_images=final_view_images,
            final_assessment=final_assessment
        )

    def _render_views(
        self,
        scad_path: str,
        output_dir: str,
        timestamp: str,
        iteration: int
    ) -> Dict[str, str]:
        """Render 6 orthographic views."""
        try:
            results = self.renderer.render_all_views(
                scad_path,
                output_dir,
                prefix=f"{timestamp}_iter{iteration}",
                views=ORTHO_VIEW_NAMES
            )
            return results
        except Exception as e:
            print(f"[VLM Correction] Render error: {e}")
            return {}

    def _render_views_with_timeout_detection(
        self,
        scad_path: str,
        output_dir: str,
        timestamp: str,
        iteration: int
    ) -> Tuple[Dict[str, str], bool]:
        """
        Render views with timeout detection.

        Returns:
            Tuple of (view_images dict, timed_out flag)
        """
        timed_out = False
        try:
            results = self.renderer.render_all_views(
                scad_path,
                output_dir,
                prefix=f"{timestamp}_iter{iteration}",
                views=ORTHO_VIEW_NAMES
            )

            # Check if we got any results - empty results after render attempt
            # usually means timeout or failure
            if not results:
                # Check if this was a timeout by looking for partial renders
                timed_out = True  # Assume timeout on empty results
                print(f"[VLM Correction] Render returned empty results (likely timeout)")

            return results, timed_out

        except Exception as e:
            error_str = str(e).lower()
            # Detect timeout in exception message
            if "timeout" in error_str or "timed out" in error_str:
                timed_out = True
                print(f"[VLM Correction] Render timeout detected: {e}")
            else:
                print(f"[VLM Correction] Render error: {e}")
            return {}, timed_out

    def _render_views_extended(
        self,
        scad_path: str,
        output_dir: str,
        timestamp: str,
        iteration: int
    ) -> Dict[str, str]:
        """
        Render views with extended timeout.

        Used after auto-fix to give the fixed code more time.
        """
        try:
            results = self.extended_renderer.render_all_views(
                scad_path,
                output_dir,
                prefix=f"{timestamp}_iter{iteration}_fixed",
                views=ORTHO_VIEW_NAMES
            )
            return results
        except Exception as e:
            print(f"[VLM Correction] Extended render error: {e}")
            return {}

    def _attempt_autofix(
        self,
        code: str,
        original_prompt: str,
        timeout_occurred: bool = True,
        error_message: Optional[str] = None
    ) -> Optional[str]:
        """
        Attempt to fix SCAD code using LLM-based auto-fixer.

        This is used when render times out due to expensive operations
        like minkowski() or incorrect syntax like rotate(360).

        Args:
            code: The problematic SCAD code
            original_prompt: Original design request
            timeout_occurred: Whether a timeout triggered this
            error_message: Optional error from OpenSCAD

        Returns:
            Fixed code or None if fix failed
        """
        try:
            result = self.auto_fixer.fix(
                scad_code=code,
                original_prompt=original_prompt,
                timeout_occurred=timeout_occurred,
                error_message=error_message
            )

            if result.success:
                print(f"[VLM Correction] Auto-fix succeeded:")
                print(f"  Issues found: {result.issues_found}")
                print(f"  Changes made: {result.changes_made}")
                return result.fixed_code
            else:
                print(f"[VLM Correction] Auto-fix failed: {result.error}")
                return None

        except Exception as e:
            print(f"[VLM Correction] Auto-fix exception: {e}")
            return None

    def _image_to_base64(self, image_path: str) -> str:
        """Convert image file to base64 data URL."""
        with open(image_path, "rb") as f:
            data = base64.b64encode(f.read()).decode("utf-8")
        return f"data:image/png;base64,{data}"
    
    def _build_kb_reference_context(self, kb_components: List[Any]) -> str:
        """
        Build text context about KB reference images.
        
        Args:
            kb_components: List of KBComponentContext objects
            
        Returns:
            Formatted string describing reference images
        """
        if not kb_components:
            return ""
        
        sections = []
        sections.append("## KNOWLEDGE BASE REFERENCE IMAGES:")
        sections.append("The following reference images show what the expected components should look like.")
        sections.append("Compare the generated model against these references:\n")
        
        for kb_comp in kb_components:
            component_name = getattr(kb_comp, 'component_name', 'unknown')
            module_name = getattr(kb_comp, 'module_name', 'unknown')
            confidence = getattr(kb_comp, 'confidence', 0.5)
            sections.append(f"- {component_name} (module: {module_name}, confidence: {confidence:.2f})")
        
        sections.append("\nUse these references to verify that the generated model contains")
        sections.append("components matching the expected shapes and structures.")
        
        return "\n".join(sections)
    
    def _get_kb_reference_images(self, kb_components: List[Any]) -> Dict[str, Dict[str, str]]:
        """
        Get KB reference images for components.
        
        Returns a nested dict: {component_id: {view_name: image_path}}
        
        Args:
            kb_components: List of KBComponentContext objects
            
        Returns:
            Dictionary mapping component_id to view images
        """
        if not kb_components:
            return {}
        
        # Try to import KB functions
        try:
            from kb.retriever import get_kb_context
            from kb.renderer import get_component_images
        except ImportError:
            try:
                from ..kb.retriever import get_kb_context
                from ..kb.renderer import get_component_images
            except ImportError:
                return {}
        
        reference_images = {}
        
        for kb_comp in kb_components:
            component_id = getattr(kb_comp, 'component_id', None)
            if not component_id:
                continue
            
            # Get reference images for this component
            comp_images = get_component_images(component_id)
            
            # Filter to only views we're using (front, back, left, right, top, bottom)
            filtered_images = {}
            for view_name in ORTHO_VIEW_NAMES:
                if view_name in comp_images and comp_images[view_name] and comp_images[view_name].exists():
                    filtered_images[view_name] = str(comp_images[view_name])
            
            if filtered_images:
                reference_images[component_id] = filtered_images
        
        return reference_images

    def _vlm_assess(
        self,
        view_images: Dict[str, str],
        original_prompt: str,
        current_code: str,
        iteration: int,
        kb_components: List[Any] = None
    ) -> Optional[VLMAssessment]:
        """
        Use VLM to assess the rendered views.

        Sends all 6 images + prompt to the model for assessment.
        Includes KB reference images if available.
        Uses concise prompts for reasoning models (GPT-5.2).
        """
        if not view_images:
            return None

        try:
            # Build KB reference context if available
            kb_reference_context = self._build_kb_reference_context(kb_components) if kb_components else ""
            
            # Use concise prompt for reasoning models, detailed for others
            if self.model in REASONING_MODELS:
                text_prompt = REASONING_MODEL_ASSESS_PROMPT.format(
                    original_prompt=original_prompt
                )
                if kb_reference_context:
                    text_prompt += "\n\n" + kb_reference_context
            else:
                # Detailed prompt for non-reasoning models (GPT-4o)
                text_prompt = f"""You are evaluating a 3D CAD model generated from a text description.

ORIGINAL REQUEST:
{original_prompt}

Below are 6 orthographic views of the generated model (front, back, left, right, top, bottom).
Assess if the model matches the original request with FOCUS ON ESSENTIAL PARTS.

## CRITICAL - BLANK IMAGE CHECK:
FIRST, check if the images show ANY visible 3D object. If the images appear:
- Completely blank, black, or uniform color
- Show no visible geometry or shape
- Display only the background with no object

Then you MUST respond with:
- "approved": false
- "confidence": 0.0
- "overall_match": "poor"
- issues: ["Images appear blank or empty - no visible 3D geometry rendered"]

Do NOT approve blank or empty renders under any circumstances.

## EVALUATION PRIORITY (only if images show visible geometry):

**HIGH PRIORITY (Essential)**: Main body shape, core structural elements, primary functional parts
- These MUST be correct for approval
- Example: For a car, the body shape and wheels are essential

**MEDIUM PRIORITY (Secondary)**: Supporting features like bumpers, windows, doors
- Should be present but minor issues are acceptable
- Don't fail the model for small secondary issues

**LOW PRIORITY (Optional)**: Details like handles, decorations, fine features
- Nice to have but NOT required for approval
- Ignore missing optional details

## APPROVAL CRITERIA:

- "approved": true if ESSENTIAL parts are correct, even if secondary/optional are imperfect
- "confidence": 0.85+ if essential parts are good (don't be overly strict)
- Focus on the RECOGNIZABLE SHAPE, not perfection
- A blocky/simplified version is ACCEPTABLE if the object is identifiable

Respond with JSON:
{{
    "approved": true/false,
    "confidence": 0.0-1.0,
    "overall_match": "good" | "partial" | "poor",
    "issues": ["only list SIGNIFICANT issues with essential parts"],
    "suggestions": ["prioritized fixes, essential parts first"],
    "view_assessments": {{
        "front": "assessment",
        "back": "assessment",
        "left": "assessment",
        "right": "assessment",
        "top": "assessment",
        "bottom": "assessment"
    }}
}}

IMPORTANT:
- Be LENIENT - approve if the object is recognizable
- Don't penalize for missing fine details
- Focus on overall shape and essential components"""
                if kb_reference_context:
                    text_prompt += "\n\n" + kb_reference_context

            # Get KB reference images for vision API
            kb_reference_images = self._get_kb_reference_images(kb_components) if kb_components else {}
            
            # Call vision API (handles both Responses API and Chat Completions API)
            result_text = self._call_vision_api(
                text_prompt=text_prompt,
                view_images=view_images,
                view_names=ORTHO_VIEW_NAMES,
                max_tokens=2000,
                temperature=0.2,
                json_response=True,
                reference_images=kb_reference_images
            )

            result = self._extract_json(result_text)

            return VLMAssessment(
                iteration=iteration,
                approved=result.get("approved", False),
                confidence=result.get("confidence", 0.5),
                issues=result.get("issues", []),
                suggestions=result.get("suggestions", []),
                overall_match=result.get("overall_match", "poor"),
                view_assessments=result.get("view_assessments", {})
            )

        except Exception as e:
            print(f"[VLM Correction] Assessment error: {e}")
            return VLMAssessment(
                iteration=iteration,
                approved=False,
                confidence=0.0,
                issues=[f"Assessment failed: {str(e)}"],
                suggestions=[],
                overall_match="poor",
                view_assessments={}
            )

    def _vlm_correct(
        self,
        current_code: str,
        original_prompt: str,
        view_images: Dict[str, str],
        vlm_assessment: Optional[VLMAssessment],
        det_result: ValidationResult
    ) -> Optional[str]:
        """
        Use VLM to generate corrected SCAD code.

        Sends images + issues + current code to get a corrected version.
        """
        if not vlm_assessment:
            return None

        try:
            # Build correction prompt
            issues_text = "\n".join(f"- {issue}" for issue in vlm_assessment.issues)
            suggestions_text = "\n".join(f"- {s}" for s in vlm_assessment.suggestions)
            det_issues_text = "\n".join(f"- {issue}" for issue in det_result.issues)

            # Use concise prompt for reasoning models, detailed for others
            if self.model in REASONING_MODELS:
                text_prompt = REASONING_MODEL_FIX_PROMPT.format(
                    original_prompt=original_prompt,
                    issues=issues_text if issues_text else "Model needs improvement",
                    current_code=current_code
                )
            else:
                # Detailed prompt for non-reasoning models (GPT-4o)
                text_prompt = f"""You are an expert OpenSCAD programmer. Fix the code to better match the original request.

ORIGINAL REQUEST:
{original_prompt}

VISUAL ISSUES (PRIORITIZE ESSENTIAL PARTS):
{issues_text if issues_text else "No specific issues noted"}

SUGGESTED FIXES:
{suggestions_text if suggestions_text else "No specific suggestions"}

CURRENT CODE:
```openscad
{current_code}
```

## OPENSCAD BEST PRACTICES (from NopSCADlib):

1. **Parametric Design**: ALL dimensions as variables at top
   ```openscad
   body_length = 100;
   body_width = 50;
   wheel_radius = 15;
   ```

2. **Modular Parts**: Each part as a module
   ```openscad
   module body() {{ cube([body_length, body_width, body_height], center=true); }}
   module wheel() {{ cylinder(r=wheel_radius, h=10, center=true); }}
   ```

3. **Union Assembly**: Combine all parts
   ```openscad
   union() {{
       body();
       translate([x, y, z]) wheel();
   }}
   ```

4. **Proper Positioning**: Use translate() to position parts correctly
5. **Center Symmetric Parts**: Use center=true

## FIX PRIORITIES:

1. **ESSENTIAL FIRST**: Fix main body shape, core structure, primary parts
2. **Then Secondary**: Fix supporting features if time/context allows
3. **Skip Optional**: Don't worry about fine details

**CONNECTIVITY IS CRITICAL - FIX DISCONNECTED PARTS:**

WRONG - attachment floats above body:
```
body_h = 30; attach_h = 20;
translate([0, 0, 60]) cylinder(h=attach_h);  // 60 is arbitrary!
```

CORRECT - attachment connects to body:
```
body_h = 30; attach_h = 20;
translate([0, 0, body_h/2 + attach_h/2 - 1]) cylinder(h=attach_h, center=true);  // calculated!
```

WRONG - side part disconnected:
```
main_w = 50; side_w = 20;
translate([100, 0, 0]) cube([side_w, 20, 20]);  // 100 >> 50, floats away!
```

CORRECT - side part attached:
```
main_w = 50; side_w = 20;
translate([main_w/2 + side_w/2 - 1, 0, 0]) cube([side_w, 20, 20], center=true);  // 25+10-1=34
```

RADIAL ARRAY (gears, fans) - teeth PROTRUDE OUT, inner edge INSIDE hub:
```
overlap = 2;
union() {{
    cylinder(r=hub_r, h=hub_h, center=true);
    for (i = [0:n-1]) rotate([0,0,i*360/n]) translate([hub_r + len/2 - overlap, 0, 0]) cube([len,w,hub_h], center=true);
}}
```

LOOP HANDLE (mugs) - must connect at TWO points, not a single peg:
```
union() {{
    cylinder(r=body_r, h=h, center=true);
    translate([body_r-2,0,0]) hull() {{
        translate([12,0,15]) sphere(4); translate([12,0,-15]) sphere(4);
        translate([0,0,15]) sphere(4); translate([0,0,-15]) sphere(4);
    }}
}}
```

HOLLOW (cups, boxes) - use difference:
```
difference() {{ cylinder(r=40,h=60,center=true); translate([0,0,3]) cylinder(r=37,h=60,center=true); }}
```

**RULES:**
- translate() = formula from dimensions, NOT arbitrary numbers
- Radial: for+rotate+translate([radius-1,0,0])
- Handles: LOOP back with hull(), not single cylinder
- Hollow: difference() with inner shape

CRITICAL REQUIREMENTS:
1. MUST make actual changes - do NOT return the same code
2. Focus on ESSENTIAL parts first (main shape, core components)
3. **ALL PARTS MUST CONNECT** - verify positions make contact
4. Use proper union() to combine ALL parts into one solid
5. Keep parametric structure (variables for dimensions)
6. Output ONLY valid OpenSCAD code, no explanations
7. Ensure model is RECOGNIZABLE as the requested object
8. NEVER add text, labels, logos, or branding - only pure geometric shapes

If views appear blank:
- Use larger dimensions (50-100mm minimum)
- Check geometry is valid (positive dimensions)
- Use center=true for symmetric shapes

CORRECTED CODE:"""

            # Call vision API (handles both Responses API and Chat Completions API)
            corrected_code = self._call_vision_api(
                text_prompt=text_prompt,
                view_images=view_images,
                view_names=ORTHO_VIEW_NAMES,
                max_tokens=4000,
                temperature=0.1,
                json_response=False  # We want code, not JSON
            )

            # Clean up the response (remove markdown code blocks if present)
            corrected_code = self._extract_scad_code(corrected_code)

            # Validate the corrected code has basic structure
            if corrected_code and len(corrected_code) > 50:
                return corrected_code

            return None

        except Exception as e:
            print(f"[VLM Correction] Correction error: {e}")
            return None

    def _extract_scad_code(self, text: str) -> str:
        """Extract SCAD code from response, handling markdown blocks."""
        # Try to find code block
        code_block_pattern = r'```(?:openscad|scad)?\s*([\s\S]*?)```'
        matches = re.findall(code_block_pattern, text)

        if matches:
            return matches[0].strip()

        # If no code block, return cleaned text
        # Remove any leading/trailing markdown artifacts
        text = text.strip()
        if text.startswith("```"):
            lines = text.split("\n")
            text = "\n".join(lines[1:])
        if text.endswith("```"):
            text = text[:-3]

        return text.strip()

    def _extract_json(self, text: str) -> Dict[str, Any]:
        """
        Robustly extract JSON from text, handling markdown code blocks
        and other formatting issues that LLMs sometimes produce.
        """
        # Try direct parse first
        try:
            return json.loads(text)
        except json.JSONDecodeError:
            pass

        # Try to find JSON in code blocks
        json_block_pattern = r'```(?:json)?\s*([\s\S]*?)```'
        matches = re.findall(json_block_pattern, text)

        for match in matches:
            try:
                return json.loads(match.strip())
            except json.JSONDecodeError:
                continue

        # Try to find JSON object pattern
        json_obj_pattern = r'\{[\s\S]*\}'
        obj_matches = re.findall(json_obj_pattern, text)

        for match in obj_matches:
            try:
                return json.loads(match)
            except json.JSONDecodeError:
                continue

        # Return safe defaults if nothing works
        print(f"[VLM] Failed to extract JSON from: {text[:200]}...")
        return {
            "approved": False,
            "confidence": 0.5,
            "issues": ["Failed to parse VLM response"],
            "suggestions": [],
            "overall_match": "poor",
            "view_assessments": {}
        }

    def _attempt_syntax_fix(self, code: str, prompt: str) -> str:
        """
        Attempt basic syntax fix using LLM (no images).

        Uses the appropriate API based on model (Responses API for GPT-5.2,
        Chat Completions API for others).
        """
        try:
            system_prompt = "You are an OpenSCAD expert. Fix syntax errors in the code."
            user_prompt = f"""Fix any syntax errors in this OpenSCAD code:

```openscad
{code}
```

Original intent: {prompt}

Return ONLY the corrected code, no explanations."""

            if self.model in RESPONSES_API_VISION_MODELS:
                # Use Responses API for GPT-5.2
                content_parts = [
                    {"type": "input_text", "text": f"CONTEXT: {system_prompt}\n\n{user_prompt}"}
                ]

                response = self.client.responses.create(
                    model=self.model,
                    input=[{"role": "user", "content": content_parts}],
                    temperature=0,
                    max_output_tokens=4000
                )

                fixed = response.output_text
            else:
                # Use Chat Completions API for GPT-4o/GPT-5.1
                response = self.client.chat.completions.create(
                    model=self.model,
                    messages=[
                        {"role": "system", "content": system_prompt},
                        {"role": "user", "content": user_prompt}
                    ],
                    temperature=0,
                    **self._get_token_param(4000)
                )

                fixed = response.choices[0].message.content

            return self._extract_scad_code(fixed)

        except Exception as e:
            print(f"[VLM Correction] Syntax fix error: {e}")
            return code


# =============================================================================
# CONVENIENCE FUNCTION
# =============================================================================

def run_visual_correction(
    client,
    model: str,
    scad_code: str,
    original_prompt: str,
    expected_parts: List[str],
    scad_path: str,
    timestamp: str,
    max_iterations: int = MAX_VLM_ITERATIONS,
    image_dir: str = "static/images"
) -> VisualCorrectionResult:
    """
    Convenience function to run visual correction loop.

    Args:
        client: Unified LLM client
        model: Model name
        scad_code: Initial SCAD code
        original_prompt: User's original prompt
        expected_parts: Expected component names
        scad_path: Path to SCAD file
        timestamp: Timestamp for naming
        max_iterations: Max correction iterations
        image_dir: Directory for images

    Returns:
        VisualCorrectionResult
    """
    corrector = VisualSelfCorrector(
        client=client,
        model=model,
        max_iterations=max_iterations,
        image_dir=image_dir
    )

    return corrector.run_correction_loop(
        scad_code=scad_code,
        original_prompt=original_prompt,
        expected_parts=expected_parts,
        scad_path=scad_path,
        timestamp=timestamp
    )
