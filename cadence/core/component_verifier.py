"""
CADence Component Verifier

This module provides targeted connectivity and component verification after VLM correction.

The process:
1. Check if all expected_parts from design brief are present (via VLM)
2. Verify the model is a single connected component (no floating parts)
3. Check that all parts are properly attached
4. Provide targeted fix prompts for specific disconnection issues

This runs AFTER the VLM self-correction loop to catch structural issues.
"""

import os
import base64
import json
import re
import time
from typing import Dict, Any, Optional, List, Tuple
from dataclasses import dataclass, field
from datetime import datetime

from utils.openscad_runner import OpenScadRunner, RenderMode
from utils.rendering import STANDARD_VIEWS, ORTHO_VIEWS, MultiViewRenderer


# =============================================================================
# CONFIGURATION
# =============================================================================

MAX_COMPONENT_ITERATIONS = int(os.getenv("MAX_COMPONENT_ITERATIONS", "3"))

# Tiered confidence thresholds for part verification (KB-augmented mode)
ESSENTIAL_PART_THRESHOLD = 0.85   # Essential parts MUST have 85%+ confidence
SECONDARY_PART_THRESHOLD = 0.65   # Secondary parts should have 65%+ confidence
OPTIONAL_PART_THRESHOLD = 0.50    # Optional parts only need 50%+ confidence

# Holistic mode thresholds (for non-KB prompts - more lenient)
HOLISTIC_MATCH_THRESHOLD = 0.60   # Overall model should match request at 60%+
HOLISTIC_FEATURE_THRESHOLD = 0.50  # Individual features need 50%+ confidence

# Models that use max_completion_tokens instead of max_tokens
NEW_API_MODELS = {"gpt-5.1", "gpt-5.2", "o1", "o1-mini", "o1-preview", "o3", "o3-mini"}

# Models that require Responses API for vision (input_image format)
RESPONSES_API_VISION_MODELS = {"gpt-5.2"}

# Retry configuration
MAX_API_RETRIES = 3
RETRY_DELAY_BASE = 2  # Base delay in seconds for exponential backoff


# =============================================================================
# DATA CLASSES
# =============================================================================

@dataclass
class PartPresenceCheck:
    """Result of checking if a part is present."""
    part_name: str
    present: bool
    confidence: float
    notes: str
    tier: str = "secondary"  # "essential", "secondary", or "optional"
    meets_threshold: bool = True  # Whether confidence meets tier threshold


@dataclass
class ConnectivityCheck:
    """Result of checking model connectivity."""
    is_single_object: bool
    floating_parts: List[str]
    attachment_issues: List[str]
    confidence: float


@dataclass
class HolisticVerificationResult:
    """Result of holistic (semantic) verification for non-KB prompts."""
    matches_request: bool
    confidence: float
    overall_assessment: str
    features_present: List[Dict[str, Any]]  # [{feature, present, confidence, notes}]
    missing_critical_features: List[str]
    suggestions: List[str]


@dataclass
class ComponentVerificationResult:
    """Result of a single verification iteration."""
    iteration: int
    parts_present: List[PartPresenceCheck]
    connectivity: ConnectivityCheck
    all_parts_found: bool
    is_connected: bool
    issues: List[str]
    fix_prompt: Optional[str]
    corrected: bool


@dataclass
class ComponentVerificationOutput:
    """Final output of the component verification loop."""
    success: bool
    final_code: str
    iterations: int
    all_parts_present: bool
    is_fully_connected: bool
    iteration_history: List[ComponentVerificationResult]
    final_issues: List[str]


# =============================================================================
# COMPONENT VERIFIER
# =============================================================================

class ComponentVerifier:
    """
    Targeted component verification for structural integrity.

    Runs after VLM correction to check:
    1. All expected parts are present
    2. Model is a single connected object
    3. Parts are properly attached
    """

    def __init__(
        self,
        client,
        model: str,
        max_iterations: int = MAX_COMPONENT_ITERATIONS,
        image_dir: str = "static/images"
    ):
        """
        Initialize the component verifier.

        Args:
            client: Unified LLM client
            model: Model to use for verification
            max_iterations: Maximum verification/fix iterations
            image_dir: Directory for view images
        """
        self.client = client
        self.model = model
        self.max_iterations = max_iterations
        self.image_dir = image_dir

        # Multi-view renderer (increased timeout for complex models)
        self.renderer = MultiViewRenderer(
            imgsize=(400, 400),
            distance=200,
            timeout=300  # 5 minutes per view for high-quality renders
        )

    def _get_token_param(self, max_tokens: int) -> Dict[str, int]:
        """Get the correct token limit parameter based on model."""
        if self.model in NEW_API_MODELS:
            return {"max_completion_tokens": max_tokens}
        return {"max_tokens": max_tokens}

    def _call_vision_api(
        self,
        text_prompt: str,
        view_images: Dict[str, str],
        view_names: List[str],
        max_tokens: int = 1500,
        temperature: float = 0.2,
        json_response: bool = True,
        reference_images: Dict[str, Dict[str, str]] = None
    ) -> str:
        """
        Call the appropriate vision API based on model.

        - GPT-5.2: Uses Responses API with input_image format
        - GPT-4o/GPT-5.1: Uses Chat Completions API with image_url format

        Includes retry logic with exponential backoff.

        Args:
            text_prompt: The text instruction
            view_images: Dict of view_name -> image_path
            view_names: List of view names to include
            max_tokens: Maximum tokens in response
            temperature: Sampling temperature
            json_response: Whether to request JSON format
            reference_images: Optional dict of {component_id: {view_name: image_path}}

        Returns:
            The response text from the model
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
                    print(f"[Component Verifier] API call failed (attempt {attempt + 1}), retrying in {delay}s: {e}")
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
                    # Add label
                    content_parts.append({
                        "type": "text",
                        "text": f"\n{view_name.upper()} VIEW:"
                    })
                    # Add image
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

    def verify_and_fix(
        self,
        scad_code: str,
        expected_parts: List[str],
        original_prompt: str,
        scad_path: str,
        timestamp: str,
        existing_view_images: Optional[Dict[str, str]] = None,
        essential_parts: Optional[List[str]] = None,
        secondary_parts: Optional[List[str]] = None,
        optional_parts: Optional[List[str]] = None,
        kb_components: Optional[List[Any]] = None
    ) -> ComponentVerificationOutput:
        """
        Run the component verification and fix loop with TIERED thresholds.

        Args:
            scad_code: Current SCAD code
            expected_parts: List of expected component names (all parts)
            original_prompt: Original user prompt
            scad_path: Path to SCAD file
            timestamp: Timestamp for file naming
            existing_view_images: View images from previous VLM stage (optional)
            essential_parts: Parts that MUST be present (high threshold)
            secondary_parts: Parts that SHOULD be present (medium threshold)
            optional_parts: Parts that are NICE to have (low threshold)

        Returns:
            ComponentVerificationOutput with results
        """
        # Default to treating all parts as secondary if no tiers provided
        essential_parts = essential_parts or []
        secondary_parts = secondary_parts or []
        optional_parts = optional_parts or []

        # Build tier lookup for quick access
        part_tiers = {}
        for part in essential_parts:
            part_tiers[part.lower()] = "essential"
        for part in secondary_parts:
            part_tiers[part.lower()] = "secondary"
        for part in optional_parts:
            part_tiers[part.lower()] = "optional"
        # Any parts not in tiers default to secondary
        for part in expected_parts:
            if part.lower() not in part_tiers:
                part_tiers[part.lower()] = "secondary"

        iteration_history = []
        current_code = scad_code
        current_scad_path = scad_path

        # Determine verification mode: holistic (non-KB) vs KB-augmented
        is_holistic_mode = not kb_components or len(kb_components) == 0
        if is_holistic_mode:
            print(f"[Component Verifier] Using HOLISTIC mode (no KB components)")
        else:
            print(f"[Component Verifier] Using KB-AUGMENTED mode ({len(kb_components)} components)")

        for iteration in range(1, self.max_iterations + 1):
            print(f"[Component Verifier] Iteration {iteration}/{self.max_iterations}")

            # Step 1: Save current code
            with open(current_scad_path, "w", encoding="utf-8") as f:
                f.write(current_code)

            # Step 2: Get view images (reuse from VLM if available and it's iteration 1)
            if iteration == 1 and existing_view_images:
                view_images = existing_view_images
            else:
                view_dir = os.path.join(self.image_dir, f"{timestamp}_comp_iter{iteration}")
                os.makedirs(view_dir, exist_ok=True)
                view_images = self._render_views(current_scad_path, view_dir, timestamp, iteration)

            if not view_images:
                print(f"[Component Verifier] Render failed on iteration {iteration}")
                break

            # Step 3: Check part presence - BRANCH based on mode
            holistic_result = None
            if is_holistic_mode:
                # HOLISTIC MODE: Semantic verification for non-KB prompts
                holistic_result, parts_check = self._check_holistic_presence(
                    view_images, expected_parts, original_prompt
                )
            else:
                # KB-AUGMENTED MODE: Part-by-part verification with reference images
                parts_check = self._check_parts_presence(
                    view_images, expected_parts, original_prompt, part_tiers,
                    kb_components=kb_components
                )

            # Step 4: Check connectivity (focus on essential parts)
            connectivity_check = self._check_connectivity(
                view_images, essential_parts or expected_parts, original_prompt
            )

            # Determine overall status - BRANCH based on mode
            if is_holistic_mode:
                # HOLISTIC MODE: Use semantic match result
                all_parts_found = (
                    holistic_result.matches_request and
                    holistic_result.confidence >= HOLISTIC_MATCH_THRESHOLD and
                    len(holistic_result.missing_critical_features) == 0
                )
                # In holistic mode, be lenient about connectivity if the overall shape matches
                is_connected = (
                    connectivity_check.is_single_object or
                    (holistic_result.matches_request and holistic_result.confidence >= 0.7)
                )
            else:
                # KB-AUGMENTED MODE: TIERED logic - only essential parts MUST be present
                essential_ok = all(
                    p.meets_threshold for p in parts_check
                    if p.tier == "essential"
                )
                # Secondary parts should mostly be present
                secondary_ok = sum(
                    1 for p in parts_check
                    if p.tier == "secondary" and p.meets_threshold
                ) >= len([p for p in parts_check if p.tier == "secondary"]) * 0.7

                all_parts_found = essential_ok and secondary_ok
                is_connected = connectivity_check.is_single_object and len(connectivity_check.attachment_issues) == 0

            # Collect issues - BRANCH based on mode
            issues = []
            if is_holistic_mode:
                # HOLISTIC MODE: Report semantic issues
                if not holistic_result.matches_request:
                    issues.append(f"Model does not match request: {holistic_result.overall_assessment}")
                for missing in holistic_result.missing_critical_features:
                    issues.append(f"Missing critical feature: {missing}")
                # Only add connectivity issues if they're severe
                if not connectivity_check.is_single_object and holistic_result.confidence < 0.6:
                    issues.append("Model has disconnected/floating parts")
            else:
                # KB-AUGMENTED MODE: Report part-by-part issues
                for p in parts_check:
                    if p.tier == "essential" and not p.meets_threshold:
                        issues.append(f"Missing ESSENTIAL part: {p.part_name}")
                    elif p.tier == "secondary" and not p.present and p.confidence < 0.3:
                        issues.append(f"Missing secondary part: {p.part_name}")

                if not connectivity_check.is_single_object:
                    issues.append("Model has disconnected/floating parts")
                for floating in connectivity_check.floating_parts:
                    if any(floating.lower() in ep.lower() for ep in essential_parts):
                        issues.append(f"Floating essential part: {floating}")
                for attach_issue in connectivity_check.attachment_issues:
                    issues.append(f"Attachment issue: {attach_issue}")

            # Generate targeted fix prompt if needed - BRANCH based on mode
            fix_prompt = None
            if issues and iteration < self.max_iterations:
                if is_holistic_mode:
                    fix_prompt = self._generate_holistic_fix_prompt(
                        holistic_result, connectivity_check, original_prompt
                    )
                else:
                    fix_prompt = self._generate_fix_prompt(
                        parts_check, connectivity_check, expected_parts, original_prompt
                    )

            # Record iteration result
            result = ComponentVerificationResult(
                iteration=iteration,
                parts_present=parts_check,
                connectivity=connectivity_check,
                all_parts_found=all_parts_found,
                is_connected=is_connected,
                issues=issues,
                fix_prompt=fix_prompt,
                corrected=False
            )

            # Check if verification passed
            if all_parts_found and is_connected:
                print(f"[Component Verifier] All checks passed on iteration {iteration}")
                iteration_history.append(result)
                return ComponentVerificationOutput(
                    success=True,
                    final_code=current_code,
                    iterations=iteration,
                    all_parts_present=True,
                    is_fully_connected=True,
                    iteration_history=iteration_history,
                    final_issues=[]
                )

            # Step 5: Attempt targeted fix if issues found
            if fix_prompt and iteration < self.max_iterations:
                print(f"[Component Verifier] Attempting targeted fix for {len(issues)} issues...")
                corrected_code = self._apply_targeted_fix(
                    current_code, fix_prompt, view_images, original_prompt
                )

                if corrected_code and corrected_code.strip() != current_code.strip():
                    result.corrected = True
                    current_code = corrected_code
                    # Save immediately
                    with open(current_scad_path, "w", encoding="utf-8") as f:
                        f.write(current_code)
                    print(f"[Component Verifier] Code corrected on iteration {iteration}")

            iteration_history.append(result)

        # Reached max iterations
        final_result = iteration_history[-1] if iteration_history else None

        return ComponentVerificationOutput(
            success=final_result.all_parts_found and final_result.is_connected if final_result else False,
            final_code=current_code,
            iterations=len(iteration_history),
            all_parts_present=final_result.all_parts_found if final_result else False,
            is_fully_connected=final_result.is_connected if final_result else False,
            iteration_history=iteration_history,
            final_issues=final_result.issues if final_result else []
        )

    def _render_views(
        self,
        scad_path: str,
        output_dir: str,
        timestamp: str,
        iteration: int
    ) -> Dict[str, str]:
        """Render orthographic views."""
        view_names = ["front", "back", "left", "right", "top", "bottom"]
        try:
            results = self.renderer.render_all_views(
                scad_path,
                output_dir,
                prefix=f"{timestamp}_comp_iter{iteration}",
                views=view_names
            )
            return results
        except Exception as e:
            print(f"[Component Verifier] Render error: {e}")
            return {}

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
        sections.append("Reference images showing what the expected components should look like are provided below.")
        sections.append("Compare the generated model against these references to verify component presence:\n")
        
        for kb_comp in kb_components:
            component_name = getattr(kb_comp, 'component_name', 'unknown')
            module_name = getattr(kb_comp, 'module_name', 'unknown')
            confidence = getattr(kb_comp, 'confidence', 0.5)
            sections.append(f"- {component_name} (module: {module_name}, confidence: {confidence:.2f})")
        
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
            from kb.renderer import get_component_images
        except ImportError:
            try:
                from ..kb.renderer import get_component_images
            except ImportError:
                return {}
        
        reference_images = {}
        view_names = ["front", "back", "left", "right", "top", "bottom"]
        
        for kb_comp in kb_components:
            component_id = getattr(kb_comp, 'component_id', None)
            if not component_id:
                continue
            
            # Get reference images for this component
            comp_images = get_component_images(component_id)
            
            # Filter to only views we're using
            filtered_images = {}
            for view_name in view_names:
                if view_name in comp_images and comp_images[view_name] and comp_images[view_name].exists():
                    filtered_images[view_name] = str(comp_images[view_name])
            
            if filtered_images:
                reference_images[component_id] = filtered_images
        
        return reference_images

    def _check_parts_presence(
        self,
        view_images: Dict[str, str],
        expected_parts: List[str],
        original_prompt: str,
        part_tiers: Optional[Dict[str, str]] = None,
        kb_components: Optional[List[Any]] = None
    ) -> List[PartPresenceCheck]:
        """
        Check if all expected parts are visually present with TIERED thresholds.

        Uses VLM to examine views and confirm each part exists.
        Different confidence thresholds apply based on part tier.
        """
        if not expected_parts:
            return []

        part_tiers = part_tiers or {}

        try:
            # Build prompt with tier information
            parts_list = []
            for part in expected_parts:
                tier = part_tiers.get(part.lower(), "secondary")
                parts_list.append(f"- {part} ({tier.upper()})")
            parts_text = "\n".join(parts_list)

            # Build KB reference context if available
            kb_reference_context = self._build_kb_reference_context(kb_components) if kb_components else ""
            
            text_prompt = f"""You are examining a 3D CAD model to verify that expected parts are present.

ORIGINAL REQUEST:
{original_prompt}

PARTS TO VERIFY (with priority):
{parts_text}

## VERIFICATION GUIDELINES:

**ESSENTIAL parts**: Must be clearly visible and recognizable. Be STRICT.
**SECONDARY parts**: Should be present but minor issues are OK. Be MODERATE.
**OPTIONAL parts**: Nice to have. Be LENIENT - even vague presence counts.

{kb_reference_context}

Below are 6 orthographic views. For EACH part, determine if it is present.

Respond with JSON:
{{
    "parts": [
        {{
            "part_name": "exact part name from list",
            "present": true/false,
            "confidence": 0.0-1.0,
            "notes": "brief explanation"
        }}
    ]
}}

IMPORTANT:
- A simplified/blocky version of a part still counts as present
- For OPTIONAL parts, be generous with "present": true
- Focus most attention on ESSENTIAL parts
- Compare against reference images if provided"""

            # Call vision API (handles both Responses API and Chat Completions API)
            result_text = self._call_vision_api(
                text_prompt=text_prompt,
                view_images=view_images,
                view_names=["front", "back", "left", "right", "top", "bottom"],
                max_tokens=1500,
                temperature=0.2,
                json_response=True
            )

            result = self._extract_json(result_text)

            checks = []
            for part_data in result.get("parts", []):
                part_name = part_data.get("part_name", "unknown")
                confidence = part_data.get("confidence", 0.5)
                tier = part_tiers.get(part_name.lower(), "secondary")

                # Determine if meets threshold based on tier
                if tier == "essential":
                    threshold = ESSENTIAL_PART_THRESHOLD
                elif tier == "optional":
                    threshold = OPTIONAL_PART_THRESHOLD
                else:
                    threshold = SECONDARY_PART_THRESHOLD

                meets_threshold = (
                    part_data.get("present", False) and
                    confidence >= threshold
                )

                checks.append(PartPresenceCheck(
                    part_name=part_name,
                    present=part_data.get("present", False),
                    confidence=confidence,
                    notes=part_data.get("notes", ""),
                    tier=tier,
                    meets_threshold=meets_threshold
                ))

            # Ensure all expected parts have a check
            found_names = {c.part_name.lower() for c in checks}
            for part in expected_parts:
                if part.lower() not in found_names:
                    tier = part_tiers.get(part.lower(), "secondary")
                    checks.append(PartPresenceCheck(
                        part_name=part,
                        present=False,
                        confidence=0.0,
                        notes="Not evaluated by VLM",
                        tier=tier,
                        meets_threshold=False
                    ))

            return checks

        except Exception as e:
            print(f"[Component Verifier] Parts check error: {e}")
            # Return unknown status for all parts
            return [
                PartPresenceCheck(
                    part_name=part,
                    present=False,
                    confidence=0.0,
                    notes=f"Check failed: {str(e)}",
                    tier=part_tiers.get(part.lower(), "secondary"),
                    meets_threshold=False
                )
                for part in expected_parts
            ]

    def _check_connectivity(
        self,
        view_images: Dict[str, str],
        expected_parts: List[str],
        original_prompt: str
    ) -> ConnectivityCheck:
        """
        Check if the model is a single connected object.

        Uses VLM to detect floating parts or disconnected components.
        """
        try:
            parts_context = ""
            if expected_parts:
                parts_context = f"\nExpected parts: {', '.join(expected_parts)}"

            text_prompt = f"""You are examining a 3D CAD model for structural connectivity issues.

ORIGINAL REQUEST:
{original_prompt}{parts_context}

Analyze the 6 views below and determine:
1. Is this a SINGLE CONNECTED OBJECT, or are there floating/disconnected parts?
2. Are all parts properly ATTACHED to each other?
3. Are there any visible GAPS between parts that should be connected?

Respond with JSON:
{{
    "is_single_object": true/false,
    "floating_parts": ["list of parts that appear to float or are disconnected"],
    "attachment_issues": ["list of specific attachment problems, e.g., 'handle not connected to body'"],
    "confidence": 0.0-1.0,
    "explanation": "brief explanation of findings"
}}

Be strict - parts should visually touch/connect, not just be near each other."""

            # Call vision API (handles both Responses API and Chat Completions API)
            result_text = self._call_vision_api(
                text_prompt=text_prompt,
                view_images=view_images,
                view_names=["front", "back", "left", "right", "top", "bottom"],
                max_tokens=1500,
                temperature=0.2,
                json_response=True
            )

            result = self._extract_json(result_text)

            return ConnectivityCheck(
                is_single_object=result.get("is_single_object", True),
                floating_parts=result.get("floating_parts", []),
                attachment_issues=result.get("attachment_issues", []),
                confidence=result.get("confidence", 0.5)
            )

        except Exception as e:
            print(f"[Component Verifier] Connectivity check error: {e}")
            return ConnectivityCheck(
                is_single_object=False,
                floating_parts=[],
                attachment_issues=[f"Check failed: {str(e)}"],
                confidence=0.0
            )

    def _check_holistic_presence(
        self,
        view_images: Dict[str, str],
        expected_parts: List[str],
        original_prompt: str
    ) -> Tuple[HolisticVerificationResult, List[PartPresenceCheck]]:
        """
        Holistic (semantic) verification for non-KB prompts.

        Instead of checking for exact module names, this asks the VLM to verify
        that the rendered model semantically matches the user's request.

        For example, if the user asked for "A Chair" with expected_parts
        ["seat", "leg_front_left", "leg_front_right", "leg_rear_left", "leg_rear_right", "backrest"],
        this asks: "Does this look like a chair with a seat, legs, and a backrest?"

        Args:
            view_images: Dict of view_name -> image_path
            expected_parts: List of expected part names (conceptual, not module names)
            original_prompt: The user's original request

        Returns:
            Tuple of (HolisticVerificationResult, List[PartPresenceCheck])
            The PartPresenceCheck list is for compatibility with existing code.
        """
        try:
            # Build a natural description of expected features from part names
            # Group similar parts (e.g., leg_front_left, leg_rear_right -> "legs")
            feature_groups = self._group_parts_semantically(expected_parts)
            features_description = ", ".join(feature_groups)

            text_prompt = f"""You are examining a 3D CAD model to verify it matches what the user requested.

USER'S REQUEST:
"{original_prompt}"

EXPECTED FEATURES:
Based on the request, this model should have: {features_description}

Examine the 6 orthographic views below and determine:
1. Does this 3D model represent what the user requested?
2. Are the key structural features present (even if simplified or stylized)?

IMPORTANT GUIDELINES:
- Be LENIENT with style/proportions - a blocky/simplified version is acceptable
- Focus on whether the ESSENTIAL STRUCTURE is present, not perfection
- A chair with 4 legs as a single base is fine (doesn't need 4 separate leg modules)
- Simplified/merged geometry is acceptable as long as the object is recognizable

Respond with JSON:
{{
    "matches_request": true/false,
    "confidence": 0.0-1.0,
    "overall_assessment": "brief description of what you see and how well it matches",
    "features_present": [
        {{
            "feature": "name of expected feature",
            "present": true/false,
            "confidence": 0.0-1.0,
            "notes": "brief explanation"
        }}
    ],
    "missing_critical_features": ["list only truly CRITICAL missing features that make this not recognizable as the requested object"],
    "suggestions": ["optional improvements, if any"]
}}

Be generous - if it looks reasonably like what was requested, approve it."""

            # Call vision API
            result_text = self._call_vision_api(
                text_prompt=text_prompt,
                view_images=view_images,
                view_names=["front", "back", "left", "right", "top", "bottom"],
                max_tokens=1500,
                temperature=0.2,
                json_response=True
            )

            result = self._extract_json(result_text)

            # Build HolisticVerificationResult
            holistic_result = HolisticVerificationResult(
                matches_request=result.get("matches_request", False),
                confidence=result.get("confidence", 0.5),
                overall_assessment=result.get("overall_assessment", ""),
                features_present=result.get("features_present", []),
                missing_critical_features=result.get("missing_critical_features", []),
                suggestions=result.get("suggestions", [])
            )

            # Convert to PartPresenceCheck list for compatibility
            part_checks = []
            features_found = {f.get("feature", "").lower(): f for f in holistic_result.features_present}

            for part in expected_parts:
                # Try to find a matching feature
                part_lower = part.lower()
                matched_feature = None

                # Direct match
                if part_lower in features_found:
                    matched_feature = features_found[part_lower]
                else:
                    # Try partial match (e.g., "leg_front_left" matches "legs")
                    for feature_name, feature_data in features_found.items():
                        if part_lower in feature_name or feature_name in part_lower:
                            matched_feature = feature_data
                            break
                        # Also check for semantic grouping (legs, wheels, etc.)
                        base_part = part_lower.split('_')[0]  # "leg" from "leg_front_left"
                        if base_part in feature_name or feature_name.startswith(base_part):
                            matched_feature = feature_data
                            break

                if matched_feature:
                    confidence = matched_feature.get("confidence", 0.5)
                    present = matched_feature.get("present", False)
                    meets_threshold = present and confidence >= HOLISTIC_FEATURE_THRESHOLD
                    part_checks.append(PartPresenceCheck(
                        part_name=part,
                        present=present,
                        confidence=confidence,
                        notes=matched_feature.get("notes", ""),
                        tier="essential",  # Treat all as essential in holistic mode
                        meets_threshold=meets_threshold
                    ))
                else:
                    # Part not explicitly checked - infer from overall match
                    # If the overall model matches, assume grouped parts are present
                    inferred_present = holistic_result.matches_request and holistic_result.confidence >= HOLISTIC_MATCH_THRESHOLD
                    part_checks.append(PartPresenceCheck(
                        part_name=part,
                        present=inferred_present,
                        confidence=holistic_result.confidence if inferred_present else 0.3,
                        notes="Inferred from overall model match" if inferred_present else "Not explicitly verified",
                        tier="secondary",
                        meets_threshold=inferred_present
                    ))

            return holistic_result, part_checks

        except Exception as e:
            print(f"[Component Verifier] Holistic check error: {e}")
            # Return failure result
            return HolisticVerificationResult(
                matches_request=False,
                confidence=0.0,
                overall_assessment=f"Verification failed: {str(e)}",
                features_present=[],
                missing_critical_features=["Verification failed"],
                suggestions=[]
            ), [
                PartPresenceCheck(
                    part_name=part,
                    present=False,
                    confidence=0.0,
                    notes=f"Check failed: {str(e)}",
                    tier="essential",
                    meets_threshold=False
                )
                for part in expected_parts
            ]

    def _group_parts_semantically(self, parts: List[str]) -> List[str]:
        """
        Group similar part names into semantic features.

        For example:
        - ["leg_front_left", "leg_front_right", "leg_rear_left", "leg_rear_right"] -> ["four legs"]
        - ["wheel_1", "wheel_2", "wheel_3", "wheel_4"] -> ["four wheels"]
        - ["seat", "backrest"] -> ["seat", "backrest"]

        This makes the verification prompt more natural and semantic.
        """
        # Count base parts (part name before underscore or number)
        base_counts = {}
        standalone_parts = []

        for part in parts:
            # Extract base name
            part_lower = part.lower()

            # Check for numbered/positioned variants
            base = part_lower
            for suffix in ['_left', '_right', '_front', '_rear', '_back', '_top', '_bottom',
                          '_1', '_2', '_3', '_4', '_5', '_6', '_7', '_8']:
                if part_lower.endswith(suffix):
                    base = part_lower[:-len(suffix)]
                    break

            # Also handle patterns like "wheel1", "leg2"
            import re
            match = re.match(r'^([a-z_]+?)[\d_]*$', part_lower)
            if match:
                potential_base = match.group(1).rstrip('_')
                if potential_base != part_lower:
                    base = potential_base

            if base != part_lower:
                # This is a variant, count it
                base_counts[base] = base_counts.get(base, 0) + 1
            else:
                # Standalone part
                standalone_parts.append(part_lower)

        # Build grouped features
        grouped_features = []

        # Add grouped parts with counts
        count_words = {1: "a", 2: "two", 3: "three", 4: "four", 5: "five", 6: "six"}
        for base, count in base_counts.items():
            if count > 1:
                count_word = count_words.get(count, str(count))
                # Pluralize
                plural = base + "s" if not base.endswith('s') else base
                grouped_features.append(f"{count_word} {plural}")
            else:
                grouped_features.append(base)

        # Add standalone parts
        for part in standalone_parts:
            # Clean up underscores for readability
            clean_part = part.replace('_', ' ')
            if clean_part not in grouped_features:
                grouped_features.append(clean_part)

        return grouped_features

    def _generate_fix_prompt(
        self,
        parts_check: List[PartPresenceCheck],
        connectivity_check: ConnectivityCheck,
        expected_parts: List[str],
        original_prompt: str
    ) -> str:
        """
        Generate a targeted fix prompt based on specific issues found.
        """
        issues = []

        # Missing parts
        missing_parts = [p.part_name for p in parts_check if not p.present]
        if missing_parts:
            issues.append(f"MISSING PARTS: The following parts are missing and must be added: {', '.join(missing_parts)}")

        # Floating parts
        if connectivity_check.floating_parts:
            for floating in connectivity_check.floating_parts:
                issues.append(f"FLOATING PART: The '{floating}' appears to be floating/disconnected. It must be physically attached to the main body.")

        # Attachment issues
        for issue in connectivity_check.attachment_issues:
            issues.append(f"ATTACHMENT ISSUE: {issue}")

        # General connectivity
        if not connectivity_check.is_single_object and not connectivity_check.floating_parts:
            issues.append("CONNECTIVITY: The model appears to have disconnected parts. Ensure all parts are properly joined using union() or translated to touch.")

        if not issues:
            return ""

        issues_text = "\n".join(f"- {issue}" for issue in issues)

        return f"""The following STRUCTURAL ISSUES were found in the model:

{issues_text}

CRITICAL REQUIREMENTS FOR FIX:
1. ALL parts must be physically connected - no gaps or floating geometry
2. Use union() to combine parts into a single solid
3. Ensure parts overlap slightly (1-2mm) to guarantee proper connection
4. Position parts so they touch or intersect - proximity alone is not enough
5. Missing parts must be created and attached to the appropriate location

Original request: {original_prompt}
Expected parts: {', '.join(expected_parts)}"""

    def _generate_holistic_fix_prompt(
        self,
        holistic_result: HolisticVerificationResult,
        connectivity_check: ConnectivityCheck,
        original_prompt: str
    ) -> str:
        """
        Generate a holistic fix prompt for non-KB prompts.

        Instead of asking to add specific module parts, this asks to make the
        model better match the semantic intent of the user's request.
        """
        issues = []

        # Overall mismatch
        if not holistic_result.matches_request:
            issues.append(f"SEMANTIC MISMATCH: The model does not look like what was requested. {holistic_result.overall_assessment}")

        # Missing critical features
        for missing in holistic_result.missing_critical_features:
            issues.append(f"MISSING FEATURE: {missing}")

        # Suggestions from VLM
        for suggestion in holistic_result.suggestions[:3]:  # Limit to top 3
            issues.append(f"IMPROVEMENT: {suggestion}")

        # Connectivity issues (only if severe)
        if not connectivity_check.is_single_object and holistic_result.confidence < 0.6:
            issues.append("STRUCTURE: The model has disconnected parts that should be joined together.")

        if not issues:
            return ""

        issues_text = "\n".join(f"- {issue}" for issue in issues)

        # Build feature summary from holistic result
        feature_summary = []
        for f in holistic_result.features_present:
            status = "✓" if f.get("present", False) else "✗"
            feature_summary.append(f"{status} {f.get('feature', 'unknown')}")
        features_text = "\n".join(feature_summary) if feature_summary else "No features evaluated"

        return f"""The model needs to better match the user's request: "{original_prompt}"

CURRENT ASSESSMENT:
{holistic_result.overall_assessment}

FEATURE STATUS:
{features_text}

ISSUES TO FIX:
{issues_text}

HOLISTIC FIX REQUIREMENTS:
1. Make the model RECOGNIZABLE as "{original_prompt}"
2. Ensure the key structural features are present and properly proportioned
3. Keep the design simple - a blocky/simplified version is acceptable
4. All parts should be connected into a single solid object
5. Focus on the OVERALL SHAPE and SILHOUETTE, not fine details

Do not add text, labels, or overly complex decorations. Keep it geometric and clean."""

    def _apply_targeted_fix(
        self,
        current_code: str,
        fix_prompt: str,
        view_images: Dict[str, str],
        original_prompt: str
    ) -> Optional[str]:
        """
        Apply a targeted fix based on the specific issues identified.
        """
        try:
            text_prompt = f"""You are an expert OpenSCAD programmer. Fix the STRUCTURAL ISSUES in this code.

STRUCTURAL ISSUES TO FIX:
{fix_prompt}

CURRENT CODE:
```openscad
{current_code}
```

Below are the current views showing the issues:

**CONNECTIVITY FIX EXAMPLES:**

WRONG - part floats above:
```
body_h = 30; part_h = 20;
translate([0, 0, 60]) cylinder(h=part_h);  // 60 is arbitrary!
```
CORRECT:
```
body_h = 30; part_h = 20;
translate([0, 0, body_h/2 + part_h/2 - 1]) cylinder(h=part_h, center=true);
```

WRONG - side attachment disconnected:
```
main_w = 50;
translate([80, 0, 0]) cube([20, 20, 20]);  // 80 > 50, floats!
```
CORRECT:
```
main_w = 50; side_w = 20;
translate([main_w/2 + side_w/2 - 1, 0, 0]) cube([side_w, 20, 20], center=true);
```

RADIAL (gears/fans) - teeth PROTRUDE OUT, inner edge INSIDE hub:
```
overlap=2; for (i=[0:n-1]) rotate([0,0,i*360/n]) translate([hub_r+len/2-overlap,0,0]) cube([len,w,h], center=true);
```

LOOP HANDLE (mugs) - connects at TWO points:
```
translate([body_r-2,0,0]) hull() {{ translate([12,0,15]) sphere(4); translate([12,0,-15]) sphere(4); translate([0,0,15]) sphere(4); translate([0,0,-15]) sphere(4); }}
```

HOLLOW (cups) - difference with inner:
```
difference() {{ cylinder(r=R,h=H); translate([0,0,wall]) cylinder(r=R-wall,h=H); }}
```

**RULES:** translate()=formula, Radial=rotate+translate([r-1,0,0]), Handle=hull loop, Hollow=difference

FIX REQUIREMENTS:
1. Address EVERY structural issue listed above
2. **RECALCULATE ALL translate() VALUES** to ensure parts touch
3. Ensure all parts are connected in a single union()
4. Add slight overlap (1-2mm) between parts for solid connections
5. Do NOT change the overall design - only fix connectivity
6. Output ONLY the corrected OpenSCAD code

CORRECTED CODE:"""

            # Call vision API (handles both Responses API and Chat Completions API)
            # Use fewer views for fix (front, right, top)
            corrected_code = self._call_vision_api(
                text_prompt=text_prompt,
                view_images=view_images,
                view_names=["front", "right", "top"],
                max_tokens=4000,
                temperature=0.1,
                json_response=False  # We want code, not JSON
            )

            # Clean up the response
            corrected_code = self._extract_scad_code(corrected_code)

            if corrected_code and len(corrected_code) > 50:
                return corrected_code

            return None

        except Exception as e:
            print(f"[Component Verifier] Fix error: {e}")
            return None

    def _extract_scad_code(self, text: str) -> str:
        """Extract SCAD code from response, handling markdown blocks."""
        # Try to find code block
        code_block_pattern = r'```(?:openscad|scad)?\s*([\s\S]*?)```'
        matches = re.findall(code_block_pattern, text)

        if matches:
            return matches[0].strip()

        # If no code block, return cleaned text
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

        # Return empty dict if nothing works
        print(f"[Component Verifier] Failed to extract JSON from: {text[:200]}...")
        return {}


# =============================================================================
# CONVENIENCE FUNCTION
# =============================================================================

def run_component_verification(
    client,
    model: str,
    scad_code: str,
    expected_parts: List[str],
    original_prompt: str,
    scad_path: str,
    timestamp: str,
    max_iterations: int = MAX_COMPONENT_ITERATIONS,
    image_dir: str = "static/images",
    existing_view_images: Optional[Dict[str, str]] = None,
    essential_parts: Optional[List[str]] = None,
    secondary_parts: Optional[List[str]] = None,
    optional_parts: Optional[List[str]] = None
) -> ComponentVerificationOutput:
    """
    Convenience function to run component verification with tiered thresholds.

    Args:
        client: Unified LLM client
        model: Model name
        scad_code: Current SCAD code
        expected_parts: Expected component names (all parts)
        original_prompt: User's original prompt
        scad_path: Path to SCAD file
        timestamp: Timestamp for naming
        max_iterations: Max verification iterations
        image_dir: Directory for images
        existing_view_images: Reuse images from VLM stage
        essential_parts: Parts that MUST be present (high threshold)
        secondary_parts: Parts that SHOULD be present (medium threshold)
        optional_parts: Parts that are NICE to have (low threshold)

    Returns:
        ComponentVerificationOutput
    """
    verifier = ComponentVerifier(
        client=client,
        model=model,
        max_iterations=max_iterations,
        image_dir=image_dir
    )

    return verifier.verify_and_fix(
        scad_code=scad_code,
        expected_parts=expected_parts,
        original_prompt=original_prompt,
        scad_path=scad_path,
        timestamp=timestamp,
        existing_view_images=existing_view_images,
        essential_parts=essential_parts,
        secondary_parts=secondary_parts,
        optional_parts=optional_parts
    )
