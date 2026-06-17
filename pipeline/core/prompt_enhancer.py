"""
Prompt Enhancer for CRAFT Pipeline

Enhances vague user prompts with specific details from the Knowledge Base:
- Specific component variants (e.g., "servo motor" → "SG90 micro servo")
- Material specifications (e.g., "bracket" → "3mm aluminum bracket")
- Standard dimensions from KB component parameters
- Assembly relationships and mounting details

This addresses the quality gap between specific prompts like:
  "NEMA17 stepper motor with aluminum bracket 10mm away" (excellent results)
vs vague prompts like:
  "fan attached to servo motor" (mediocre results)
"""

import json
from dataclasses import dataclass, field
from typing import List, Dict, Optional, Any, Tuple

# KB integration
try:
    from ..kb import (
        detect_components,
        get_kb_context,
        is_kb_ready,
        DetectionResult
    )
    from ..kb.indexer import ComponentInfo, load_component_index
    from ..kb.config import COMPONENT_ALIASES, CATEGORY_KEYWORDS
    KB_AVAILABLE = True
except ImportError:
    try:
        from kb import (
            detect_components,
            get_kb_context,
            is_kb_ready,
            DetectionResult
        )
        from kb.indexer import ComponentInfo, load_component_index
        from kb.config import COMPONENT_ALIASES, CATEGORY_KEYWORDS
        KB_AVAILABLE = True
    except ImportError:
        KB_AVAILABLE = False


@dataclass
class ComponentEnhancement:
    """Enhancement details for a detected component."""
    original_term: str           # What the user said (e.g., "servo motor")
    specific_variant: str        # Specific KB component (e.g., "SG90")
    module_name: str             # KB module name
    suggested_material: str      # Suggested material for brackets/mounts
    key_dimensions: Dict[str, Any]  # Key parameters from KB
    mounting_info: str           # How it mounts/attaches
    confidence: float


@dataclass
class EnhancementResult:
    """Result of prompt enhancement."""
    original_prompt: str
    enhanced_prompt: str
    was_enhanced: bool
    components_found: List[ComponentEnhancement]
    enhancement_notes: List[str]


# Material suggestions based on component categories and use cases
MATERIAL_SUGGESTIONS = {
    # Motors typically use aluminum or steel brackets
    "motors": {
        "bracket": "aluminum",
        "mount": "aluminum",
        "plate": "3mm aluminum",
        "standoff": "aluminum",
    },
    "servos": {
        "bracket": "aluminum",
        "mount": "3D printed PLA",
        "horn": "plastic",
    },
    # Fans use metal or printed brackets
    "fans": {
        "bracket": "aluminum",
        "mount": "3D printed PETG",
        "shroud": "3D printed PLA",
        "duct": "3D printed PLA",
    },
    # Bearings need precise metal housings
    "bearings": {
        "housing": "aluminum",
        "mount": "aluminum",
        "block": "aluminum",
    },
    # Electronics often use printed mounts
    "electronics": {
        "case": "3D printed PLA",
        "mount": "3D printed PLA",
        "bracket": "3D printed PLA",
        "enclosure": "3D printed PLA",
    },
    # Default for unknown categories
    "default": {
        "bracket": "aluminum",
        "mount": "aluminum",
        "plate": "aluminum",
        "adapter": "aluminum",
    }
}

# Default standoff/spacing values (mm) by component type
DEFAULT_SPACING = {
    "fan": 10,           # 10mm spacing for airflow
    "motor": 5,          # 5mm for motor mounting
    "servo": 3,          # 3mm typical servo offset
    "bearing": 0,        # Bearings typically flush mount
    "pcb": 5,            # 5mm standoff for PCBs
    "display": 2,        # 2mm for displays
    "default": 5,        # Default 5mm spacing
}

# Component-specific mounting patterns
MOUNTING_INFO = {
    "NEMA": "4-point bolt pattern (M3 screws at 31mm spacing for NEMA17)",
    "fan": "4-corner mounting holes with standard fan screw pattern",
    "servo": "mounting tabs with 2 screw holes on each side",
    "SG90": "mounting tabs with 2 screw holes, 28mm between tab centers",
    "MG996R": "mounting tabs with 2 screw holes, 40mm between tab centers",
    "bearing": "press-fit or clamped housing",
    "linear_rail": "bolt pattern along rail length",
    "stepper": "face-mount with 4 bolts in square pattern",
}


ENHANCEMENT_SYSTEM_PROMPT = """You are a CAD design assistant that enhances vague prompts with specific technical details.

Given a user's prompt and information about detected components from NopSCADlib, create an enhanced version.

CRITICAL RULES:
1. **DO NOT ADD NEW COMPONENTS** - If the user asks for "A NEMA23 motor", output just the motor, NOT "motor with bracket"
2. Only add brackets/mounts/assemblies if the user's prompt EXPLICITLY implies multiple parts:
   - Assembly words: "on", "mounted on", "attached to", "with bracket", "connected to", "holder for"
   - Example SINGLE part: "A fan" → enhance with dimensions, NOT with mount
   - Example ASSEMBLY: "A fan on a motor" → can add bracket to connect them
3. For SINGLE components, only add:
   - Specific dimensions from KB
   - Material clarifications for the component itself
   - Technical specifications
4. Keep the original intent - if they want ONE thing, give them ONE thing

OUTPUT FORMAT (JSON):
{
    "enhanced_prompt": "The enhanced version (DO NOT add parts not implied by original)",
    "notes": ["Note about what was added"],
    "is_assembly": true/false
}"""


ENHANCEMENT_USER_TEMPLATE = """ORIGINAL PROMPT: {original_prompt}

REQUEST TYPE: {request_type}

DETECTED COMPONENTS FROM KNOWLEDGE BASE:
{component_info}

{enhancement_context}

REMEMBER:
- If REQUEST TYPE is "SINGLE COMPONENT" → DO NOT add brackets, mounts, or other parts
- If REQUEST TYPE is "ASSEMBLY" → You may add connecting parts like brackets
- Only enhance with dimensions and specifications, not new components (unless assembly)"""


class PromptEnhancer:
    """
    Enhances vague prompts with specific details from the Knowledge Base.

    This is the key to getting consistent high-quality results like the
    NEMA17+fan bracket example.
    """

    def __init__(self, client, model: str = "gpt-4o-mini"):
        """
        Initialize the enhancer.

        Args:
            client: OpenAI client instance
            model: Model to use for enhancement (fast model preferred)
        """
        self.client = client
        self.model = model
        self._components_cache: Dict[str, ComponentInfo] = {}

    def _load_components(self) -> Dict[str, ComponentInfo]:
        """Load component index if not cached."""
        if not self._components_cache and KB_AVAILABLE:
            try:
                self._components_cache = load_component_index()
            except Exception as e:
                print(f"[PromptEnhancer] Failed to load component index: {e}")
        return self._components_cache

    def _detect_components(self, prompt: str) -> Tuple[List[Dict], DetectionResult]:
        """
        Detect KB components in the prompt.

        Returns:
            Tuple of (component details list, detection result)
        """
        if not KB_AVAILABLE or not is_kb_ready():
            return [], None

        try:
            detection = detect_components(prompt)
            if not detection.has_kb_components:
                return [], detection

            # Get full component info
            components = self._load_components()
            component_details = []

            for detected in detection.detected_components:
                comp_info = components.get(detected.component_id)
                if comp_info:
                    # Extract key parameters
                    key_params = {}
                    for param in comp_info.parameters[:10]:  # Limit to key params
                        if param.default_value:
                            key_params[param.name] = param.default_value

                    component_details.append({
                        "detected_text": detected.matched_text,
                        "module_name": comp_info.module_name,
                        "name": comp_info.name,
                        "category": comp_info.category,
                        "subcategory": comp_info.subcategory,
                        "description": comp_info.description,
                        "parameters": key_params,
                        "confidence": detected.confidence,
                        "match_type": detected.match_type
                    })

            return component_details, detection

        except Exception as e:
            print(f"[PromptEnhancer] Component detection error: {e}")
            return [], None

    def _get_material_suggestion(self, category: str, part_type: str) -> str:
        """Get material suggestion for a part type in a category."""
        category_materials = MATERIAL_SUGGESTIONS.get(
            category,
            MATERIAL_SUGGESTIONS.get("default", {})
        )

        # Try to match part type
        part_lower = part_type.lower()
        for key, material in category_materials.items():
            if key in part_lower:
                return material

        # Fallback
        return MATERIAL_SUGGESTIONS["default"].get("bracket", "aluminum")

    def _get_spacing_suggestion(self, component_type: str) -> int:
        """Get default spacing suggestion for a component type."""
        type_lower = component_type.lower()

        for key, spacing in DEFAULT_SPACING.items():
            if key in type_lower:
                return spacing

        return DEFAULT_SPACING["default"]

    def _get_mounting_info(self, module_name: str) -> str:
        """Get mounting information for a component."""
        module_lower = module_name.lower()

        for key, info in MOUNTING_INFO.items():
            if key.lower() in module_lower:
                return info

        return "standard mounting pattern"

    def _build_component_info_string(self, components: List[Dict]) -> str:
        """Build a formatted string of component information."""
        if not components:
            return "No specific components detected in KB"

        lines = []
        for i, comp in enumerate(components, 1):
            lines.append(f"{i}. {comp['name']} ({comp['module_name']})")
            lines.append(f"   Category: {comp['category']}/{comp['subcategory']}")
            if comp['description']:
                lines.append(f"   Description: {comp['description'][:100]}...")
            if comp['parameters']:
                param_str = ", ".join(
                    f"{k}={v}" for k, v in list(comp['parameters'].items())[:5]
                )
                lines.append(f"   Key parameters: {param_str}")
            lines.append(f"   Confidence: {comp['confidence']:.2f}")

        return "\n".join(lines)

    def _build_material_suggestions(self, components: List[Dict], prompt: str) -> str:
        """Build material suggestions based on components and prompt."""
        suggestions = []
        prompt_lower = prompt.lower()

        # Check for custom parts mentioned in prompt
        custom_parts = ["bracket", "mount", "plate", "adapter", "holder", "stand", "frame"]

        for part in custom_parts:
            if part in prompt_lower:
                # Find relevant category
                category = "default"
                for comp in components:
                    category = comp.get("subcategory", comp.get("category", "default"))
                    break

                material = self._get_material_suggestion(category, part)
                suggestions.append(f"{part}: {material}")

        if not suggestions:
            suggestions.append("bracket/mount: aluminum (default)")

        return "; ".join(suggestions)

    def _build_spacing_suggestions(self, components: List[Dict]) -> str:
        """Build spacing suggestions based on detected components."""
        suggestions = []

        for comp in components:
            module_name = comp.get("module_name", "")
            spacing = self._get_spacing_suggestion(module_name)
            suggestions.append(f"{comp['name']}: {spacing}mm standoff")

        if not suggestions:
            suggestions.append("default: 5mm spacing")

        return "; ".join(suggestions)

    def _build_mounting_suggestions(self, components: List[Dict]) -> str:
        """Build mounting suggestions based on detected components."""
        suggestions = []

        for comp in components:
            module_name = comp.get("module_name", "")
            mounting = self._get_mounting_info(module_name)
            suggestions.append(f"{comp['name']}: {mounting}")

        return "; ".join(suggestions) if suggestions else "standard mounting"

    def _is_assembly_prompt(self, prompt: str) -> bool:
        """
        Check if the prompt implies an assembly (multiple parts) or single component.

        Returns True if prompt suggests multiple parts that need to be assembled.
        """
        prompt_lower = prompt.lower()

        # Keywords that indicate assembly/multiple parts
        assembly_keywords = [
            " on ", " on a ", " mounted on", " attached to", " connected to",
            " with bracket", " with mount", " with holder", " holder for",
            " in a ", " inside ", " around ", " for a ", " for the ",
            " and a ", " and the ",
        ]

        for keyword in assembly_keywords:
            if keyword in prompt_lower:
                return True

        return False

    def _should_enhance(self, prompt: str, components: List[Dict]) -> bool:
        """
        Determine if the prompt needs enhancement.

        Skip enhancement if:
        - Prompt is already specific enough
        - Single component request with specific model name
        """
        prompt_lower = prompt.lower()

        # Check if prompt already has specific details
        has_dimensions = any(
            unit in prompt_lower
            for unit in ["mm", "cm", "inch", "°", "degree"]
        )
        has_materials = any(
            material in prompt_lower
            for material in ["aluminum", "steel", "pla", "petg", "abs", "metal", "plastic"]
        )
        has_specific_model = any(
            comp.get("match_type") == "exact_module"
            for comp in components
        )

        # Check if this is a single-component request with specific model
        is_assembly = self._is_assembly_prompt(prompt)

        # For SINGLE component requests that already have a specific model,
        # don't enhance - the user knows what they want
        if not is_assembly and has_specific_model:
            print(f"[PromptEnhancer] Single component with specific model, skipping enhancement")
            return False

        # If prompt already has 2+ of these, it's specific enough
        specificity_score = sum([has_dimensions, has_materials, has_specific_model])

        if specificity_score >= 2:
            print(f"[PromptEnhancer] Prompt already specific (score={specificity_score}), skipping enhancement")
            return False

        # Enhance if we found KB components AND it's either:
        # 1. An assembly prompt, or
        # 2. A vague single-component prompt (no specific model)
        return len(components) > 0

    def enhance(self, prompt: str) -> EnhancementResult:
        """
        Enhance a prompt with specific details from the Knowledge Base.

        Args:
            prompt: User's original prompt

        Returns:
            EnhancementResult with enhanced prompt and metadata
        """
        # Step 1: Detect components
        components, detection = self._detect_components(prompt)

        if not components:
            print(f"[PromptEnhancer] No KB components detected, returning original")
            return EnhancementResult(
                original_prompt=prompt,
                enhanced_prompt=prompt,
                was_enhanced=False,
                components_found=[],
                enhancement_notes=["No NopSCADlib components detected"]
            )

        # Step 2: Check if enhancement is needed
        if not self._should_enhance(prompt, components):
            return EnhancementResult(
                original_prompt=prompt,
                enhanced_prompt=prompt,
                was_enhanced=False,
                components_found=[],
                enhancement_notes=["Prompt already sufficiently specific"]
            )

        # Step 3: Determine request type and build enhancement context
        is_assembly = self._is_assembly_prompt(prompt)
        request_type = "ASSEMBLY" if is_assembly else "SINGLE COMPONENT"

        component_info = self._build_component_info_string(components)

        # Build enhancement context based on request type
        if is_assembly:
            material_suggestions = self._build_material_suggestions(components, prompt)
            spacing_suggestions = self._build_spacing_suggestions(components)
            mounting_suggestions = self._build_mounting_suggestions(components)
            enhancement_context = f"""SUGGESTED ENHANCEMENTS (assembly):
- Materials for brackets/mounts: {material_suggestions}
- Spacing: {spacing_suggestions}
- Mounting: {mounting_suggestions}"""
        else:
            # For single components, only suggest dimensions
            enhancement_context = """ENHANCEMENT SCOPE (single component):
- Add specific dimensions from KB (size, length, diameter)
- Add technical specifications
- DO NOT add brackets, mounts, or other parts"""

        print(f"[PromptEnhancer] Enhancing prompt with {len(components)} KB components (type: {request_type})")

        # Step 4: Call LLM for enhancement
        try:
            user_prompt = ENHANCEMENT_USER_TEMPLATE.format(
                original_prompt=prompt,
                request_type=request_type,
                component_info=component_info,
                enhancement_context=enhancement_context
            )

            response = self.client.chat.completions.create(
                model=self.model,
                temperature=0.3,
                response_format={"type": "json_object"},
                messages=[
                    {"role": "system", "content": ENHANCEMENT_SYSTEM_PROMPT},
                    {"role": "user", "content": user_prompt}
                ]
            )

            result = json.loads(response.choices[0].message.content)
            enhanced_prompt = result.get("enhanced_prompt", prompt)
            notes = result.get("notes", [])

            # Build component enhancements
            enhancements = []
            for comp in components:
                enhancement = ComponentEnhancement(
                    original_term=comp.get("detected_text", ""),
                    specific_variant=comp.get("name", ""),
                    module_name=comp.get("module_name", ""),
                    suggested_material=self._get_material_suggestion(
                        comp.get("category", "default"), "bracket"
                    ),
                    key_dimensions=comp.get("parameters", {}),
                    mounting_info=self._get_mounting_info(comp.get("module_name", "")),
                    confidence=comp.get("confidence", 0.0)
                )
                enhancements.append(enhancement)

            print(f"[PromptEnhancer] Enhanced prompt: {enhanced_prompt[:100]}...")

            return EnhancementResult(
                original_prompt=prompt,
                enhanced_prompt=enhanced_prompt,
                was_enhanced=True,
                components_found=enhancements,
                enhancement_notes=notes
            )

        except Exception as e:
            print(f"[PromptEnhancer] LLM enhancement failed: {e}")
            # Fallback: simple enhancement without LLM
            return self._fallback_enhance(prompt, components)

    def _fallback_enhance(
        self,
        prompt: str,
        components: List[Dict]
    ) -> EnhancementResult:
        """
        Fallback enhancement without LLM call.

        Adds basic specificity using templates.
        """
        enhanced_parts = [prompt]
        notes = []

        for comp in components:
            module_name = comp.get("module_name", "")
            name = comp.get("name", "")
            params = comp.get("parameters", {})

            # Add component specificity note
            notes.append(f"Using {name} ({module_name}) from NopSCADlib")

            # Add key dimension if available
            for key in ["size", "width", "diameter", "opening"]:
                if key in params:
                    notes.append(f"  - {key}: {params[key]}mm")
                    break

        # Build simple enhanced prompt
        if components:
            component_names = [c.get("name", "") for c in components]
            enhanced_prompt = f"{prompt}. Using NopSCADlib components: {', '.join(component_names)}."

            # Add material suggestion if bracket/mount mentioned
            if any(word in prompt.lower() for word in ["bracket", "mount", "adapter"]):
                enhanced_prompt += " Use aluminum for the bracket."
        else:
            enhanced_prompt = prompt

        enhancements = [
            ComponentEnhancement(
                original_term=comp.get("detected_text", ""),
                specific_variant=comp.get("name", ""),
                module_name=comp.get("module_name", ""),
                suggested_material="aluminum",
                key_dimensions=comp.get("parameters", {}),
                mounting_info=self._get_mounting_info(comp.get("module_name", "")),
                confidence=comp.get("confidence", 0.0)
            )
            for comp in components
        ]

        return EnhancementResult(
            original_prompt=prompt,
            enhanced_prompt=enhanced_prompt,
            was_enhanced=True,
            components_found=enhancements,
            enhancement_notes=notes
        )


def enhance_prompt(client, prompt: str, model: str = "gpt-4o-mini") -> EnhancementResult:
    """
    Convenience function to enhance a prompt.

    Args:
        client: OpenAI client
        prompt: User's prompt
        model: Model to use for enhancement

    Returns:
        EnhancementResult
    """
    enhancer = PromptEnhancer(client, model)
    return enhancer.enhance(prompt)
