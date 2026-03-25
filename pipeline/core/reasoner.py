"""
CRAFT Text Reasoner

This module analyzes text prompts to extract:
- Design brief (clear description of what to build)
- Expected parts (components the model should have)
- Parameter hints (reasonable default dimensions)
- KB components (detected NopSCADlib components)

The output is a unified Design Brief that feeds into the Planner.
"""

import json
import os
from typing import Any, Dict, List, Optional
from dataclasses import dataclass, asdict, field

# KB integration (optional - gracefully handle if not available)
try:
    # Try relative import first (when running as part of package)
    from ..kb import (
        detect_components,
        get_kb_context,
        DetectionResult,
        RetrievalContext,
        is_kb_ready
    )
    from ..kb.component_filter import (
        ComponentFilter,
        AssemblyAnalyzer,
        FilterResult,
        FilteredComponent,
        ComponentRole,
        analyze_and_filter
    )
    from ..kb.dimensional_matcher import (
        match_prompt_to_component,
        DimensionalMatchResult,
    )
    KB_AVAILABLE = True
    DIMENSIONAL_MATCHER_AVAILABLE = True
except ImportError:
    try:
        # Fallback to absolute import (when running from craft directory)
        from kb import (
            detect_components,
            get_kb_context,
            DetectionResult,
            RetrievalContext,
            is_kb_ready
        )
        from kb.component_filter import (
            ComponentFilter,
            AssemblyAnalyzer,
            FilterResult,
            FilteredComponent,
            ComponentRole,
            analyze_and_filter
        )
        from kb.dimensional_matcher import (
            match_prompt_to_component,
            DimensionalMatchResult,
        )
        KB_AVAILABLE = True
        DIMENSIONAL_MATCHER_AVAILABLE = True
    except ImportError:
        KB_AVAILABLE = False
        DIMENSIONAL_MATCHER_AVAILABLE = False
        DetectionResult = None
        RetrievalContext = None
        FilterResult = None
        ComponentRole = None


@dataclass
class KBComponentContext:
    """Context for a detected KB component with role and priority."""
    component_id: str
    component_name: str
    module_name: str
    module_code: str
    parameters: List[Dict[str, Any]]
    description: str
    confidence: float
    # Role and priority from assembly analysis
    role: str = "primary"         # primary, secondary, attachment, subpart, helper
    priority: int = 1             # 1 = highest priority
    is_subpart: bool = False      # True if filtered as sub-part
    parent_module: Optional[str] = None  # Parent module if subpart


@dataclass
class DesignBrief:
    """Unified design brief structure with tiered part prioritization."""
    description: str
    expected_parts: List[str]  # All parts (for backward compatibility)
    parameters: Dict[str, float]
    source: str  # "text" or "vision"
    original_input: str
    # Tiered parts - dynamically identified by LLM
    essential_parts: List[str] = field(default_factory=list)  # MUST be present (main body, wheels, core shape)
    secondary_parts: List[str] = field(default_factory=list)  # SHOULD be present (bumpers, windows, doors)
    optional_parts: List[str] = field(default_factory=list)   # NICE to have (details, handles, decorations)
    # KB integration fields
    kb_components: List[KBComponentContext] = field(default_factory=list)
    kb_augmented: bool = False
    kb_context_prompt: str = ""
    # Assembly metadata (from component filtering)
    is_assembly: bool = False                    # True if multiple distinct KB components
    assembly_description: str = ""               # LLM-generated description of assembly
    kb_primary_component: Optional[str] = None   # Module name of primary component

    def to_dict(self) -> Dict[str, Any]:
        result = asdict(self)
        # Convert KBComponentContext objects to dicts
        result['kb_components'] = [
            asdict(c) if hasattr(c, '__dataclass_fields__') else c
            for c in self.kb_components
        ]
        return result

    def has_kb_components(self) -> bool:
        """Check if any KB components were detected (excluding sub-parts)."""
        return len([c for c in self.kb_components if not c.is_subpart]) > 0

    def get_kb_module_codes(self) -> List[str]:
        """Get all KB module codes for inclusion in generated SCAD (excluding sub-parts)."""
        return [c.module_code for c in self.kb_components if not c.is_subpart]

    def get_kb_module_names(self) -> List[str]:
        """Get all KB module names (excluding sub-parts)."""
        return [c.module_name for c in self.kb_components if not c.is_subpart]

    def get_primary_kb_component(self) -> Optional[KBComponentContext]:
        """Get the primary KB component if one exists."""
        for c in self.kb_components:
            if c.role == "primary" and not c.is_subpart:
                return c
        return None

    def get_kb_by_role(self, role: str) -> List[KBComponentContext]:
        """Get KB components by role."""
        return [c for c in self.kb_components if c.role == role and not c.is_subpart]

    def get_all_parts(self) -> List[str]:
        """Get all parts in priority order (essential first)."""
        all_parts = []
        all_parts.extend(self.essential_parts)
        all_parts.extend(self.secondary_parts)
        all_parts.extend(self.optional_parts)
        # Add any remaining expected_parts not in tiers
        for part in self.expected_parts:
            if part not in all_parts:
                all_parts.append(part)
        return all_parts


# =============================================================================
# PROMPTS
# =============================================================================

REASONER_SYSTEM_PROMPT = """You are a CAD design analyst. Your job is to analyze a user's request for a 3D model and extract structured information with PRIORITIZED PARTS.

Given a natural language description, you must identify:

1. **Design Brief**: A clear, technical description of what needs to be modeled
2. **Parts with Priority Tiers**: Categorize parts into three tiers:
   - **Essential Parts** (MUST have): Core structural components that define the object's identity. These MUST be rendered correctly.
   - **Secondary Parts** (SHOULD have): Important features that enhance the object but aren't critical to recognition.
   - **Optional Parts** (NICE to have): Details and decorations that can be omitted if complexity is too high.
3. **Parameters**: Reasonable default dimensions in millimeters (ONLY for essential and secondary parts)

## PART PRIORITIZATION EXAMPLES:

**Vehicle (car, truck):**
- Essential: body/chassis, wheels (all 4), basic cabin shape
- Secondary: bumpers, hood, trunk, basic windows
- Optional: door handles, window details, axles, headlights

**Container (box, mug, bottle):**
- Essential: main body, base
- Secondary: handle, lid/top
- Optional: decorative features, textures

**Furniture (table, chair):**
- Essential: top/seat, legs
- Secondary: back support, arm rests
- Optional: drawers, decorative elements

**Mechanical Parts:**
- Essential: main body, functional features (teeth for gears, threads for screws)
- Secondary: mounting holes, flanges
- Optional: chamfers, fillets, labels

## OPENSCAD BEST PRACTICES (from NopSCADlib):

1. **Parametric Design**: Use variables for ALL dimensions, not hardcoded values
   ```openscad
   body_length = 100;  // Main dimension
   body_width = 50;
   wheel_radius = 15;
   ```

2. **Modular Construction**: Define each part as a module
   ```openscad
   module body() { cube([body_length, body_width, body_height], center=true); }
   module wheel() { cylinder(r=wheel_radius, h=wheel_width, center=true); }
   ```

3. **Union for Assembly**: Combine parts using union()
   ```openscad
   union() {
       body();
       translate([...]) wheel();
   }
   ```

4. **Proper Centering**: Use center=true for symmetric parts

## GUIDELINES FOR PARAMETERS:
- Use realistic dimensions in millimeters (mm)
- Include ONLY parameters for essential and secondary parts
- Keep parameter names short: W, H, D, radius, thickness
- Essential parts need more parameters, optional parts need fewer

OUTPUT FORMAT (strict JSON):
{
    "brief": "Technical description of the design",
    "essential_parts": ["main_body", "wheel_1", "wheel_2", ...],
    "secondary_parts": ["bumper", "hood", ...],
    "optional_parts": ["door_handle", ...],
    "parameters": {
        "body_length": 100,
        "body_width": 50,
        "wheel_radius": 15,
        ...
    }
}

Respond ONLY with valid JSON, no explanations."""


REASONER_KB_AUGMENTED_PROMPT = """You are a CAD design analyst. Analyze the user's request and extract structured design information.

The knowledge base has detected relevant components that MAY be useful:

## REFERENCE COMPONENTS (use if relevant):
{kb_context}

## INSTRUCTIONS:
1. If the KB components match the user's intent, include their module names in essential_parts
2. If KB components are NOT relevant to the request, ignore them and design from scratch
3. Always focus on what the user actually asked for

## PART PRIORITIZATION:
- **Essential Parts**: Core structural parts that define the object
- **Secondary Parts**: Supporting features, mounting points
- **Optional Parts**: Details, decorations (NEVER include text/labels)

OUTPUT FORMAT (strict JSON):
{{
    "brief": "Technical description of the design",
    "essential_parts": ["main_body", ...],
    "secondary_parts": ["feature1", ...],
    "optional_parts": [],
    "parameters": {{
        "width": 100,
        "height": 50,
        ...
    }},
    "kb_modules_to_use": []
}}

Respond ONLY with valid JSON, no explanations."""


PART_IDENTIFICATION_PROMPT = """Analyze this object request and identify all expected components.

Object: {prompt}

List the main structural parts this object should have. Be specific and complete.
Think about:
- Main body/structure
- Attachments and features
- Functional components
- Decorative elements (if mentioned)

Output as JSON array: ["part1", "part2", ...]"""


# =============================================================================
# REASONER CLASS
# =============================================================================

class TextReasoner:
    """Analyzes text prompts to create design briefs with KB augmentation."""

    def __init__(self, client, model: str = "gpt-4o", use_kb: bool = True):
        """
        Initialize the reasoner.

        Args:
            client: OpenAI client instance
            model: Model to use for reasoning
            use_kb: Whether to use knowledge base for component detection
        """
        self.client = client
        self.model = model
        self.use_kb = use_kb and KB_AVAILABLE

    def _detect_kb_components(self, prompt: str, original_prompt: str = None) -> tuple:
        """
        Detect KB components in the prompt with filtering and prioritization.

        Args:
            prompt: The working prompt (may be enhanced)
            original_prompt: The user's original prompt (before enhancement).
                           Used to filter out hardware that wasn't explicitly requested.

        Returns:
            (detection_result, retrieval_context, kb_component_contexts, filter_result)
        """
        if not self.use_kb:
            return None, None, [], None

        try:
            # Check if KB is ready
            if not is_kb_ready():
                return None, None, [], None

            # Detect components
            detection = detect_components(prompt)
            if not detection.has_kb_components:
                return detection, None, [], None

            # Get full context for detected components
            component_ids = detection.get_component_ids()
            retrieval = get_kb_context(component_ids, prompt)

            # Step 1: Build initial KB contexts (before filtering)
            # Minimum confidence threshold - reject very low confidence matches
            KB_MIN_CONFIDENCE = 0.20  # 20% threshold

            raw_kb_contexts = []
            for result in retrieval.results:
                # Skip low-confidence matches (likely irrelevant components)
                if result.score < KB_MIN_CONFIDENCE:
                    print(f"[KB] Rejecting low-confidence match: {result.component.name} (score={result.score:.2f} < {KB_MIN_CONFIDENCE})")
                    continue

                comp = result.component
                kb_ctx = KBComponentContext(
                    component_id=comp.id,
                    component_name=comp.name,
                    module_name=comp.module_name,
                    module_code=comp.module_code,
                    parameters=[
                        {"name": p.name, "default": p.default_value, "type": p.param_type}
                        for p in comp.parameters
                    ],
                    description=comp.description or "",
                    confidence=result.score
                )
                raw_kb_contexts.append(kb_ctx)

            # Step 2: Filter and prioritize components
            # Pass original_prompt to filter out hardware that wasn't explicitly requested
            filter_result = analyze_and_filter(
                prompt=prompt,
                detected_components=raw_kb_contexts,
                client=self.client,
                model="gpt-4o-mini",  # Use fast model for filtering
                original_prompt=original_prompt or prompt  # Use original if provided
            )

            # Step 3: Build final KB contexts with role/priority info
            filtered_kb_contexts = []
            
            # Create lookup for filter results
            filter_map = {
                fc.module_name: fc 
                for fc in filter_result.filtered_components
            }
            removed_map = {
                fc.module_name: fc 
                for fc in filter_result.removed_subparts
            }

            for kb_ctx in raw_kb_contexts:
                if kb_ctx.module_name in filter_map:
                    # This is a kept component
                    fc = filter_map[kb_ctx.module_name]
                    kb_ctx.role = fc.role.value if hasattr(fc.role, 'value') else str(fc.role)
                    kb_ctx.priority = fc.priority
                    kb_ctx.is_subpart = False
                    filtered_kb_contexts.append(kb_ctx)
                elif kb_ctx.module_name in removed_map:
                    # This is a removed sub-part - mark but don't include
                    fc = removed_map[kb_ctx.module_name]
                    kb_ctx.role = "subpart"
                    kb_ctx.priority = 99
                    kb_ctx.is_subpart = True
                    kb_ctx.parent_module = fc.parent_id
                    # Don't add to filtered list - it's excluded

            # Sort by priority
            filtered_kb_contexts.sort(key=lambda c: c.priority)

            # Log filtering results
            if filter_result.removed_subparts:
                removed_names = [c.module_name for c in filter_result.removed_subparts]
                print(f"[KB Filter] Removed sub-parts: {removed_names}")
            
            if filter_result.is_assembly:
                print(f"[KB Filter] Assembly detected: {filter_result.assembly_description}")
                for fc in filter_result.filtered_components:
                    print(f"  - {fc.module_name}: {fc.role.value} (priority {fc.priority})")

            return detection, retrieval, filtered_kb_contexts, filter_result

        except Exception as e:
            print(f"KB detection error: {e}")
            import traceback
            traceback.print_exc()
            return None, None, [], None

    def _build_kb_context_string(self, retrieval: 'RetrievalContext') -> str:
        """Build context string for KB-augmented prompt."""
        if not retrieval or not retrieval.results:
            return ""

        return retrieval.get_context_prompt()

    def _try_dimensional_match(self, prompt: str) -> Optional['DimensionalMatchResult']:
        """
        Try to match the prompt to a specific NopSCADlib component using dimensions.

        This is the key innovation for the benchmark: when the prompt contains
        specific dimensions (e.g., "8mm bore, 22mm OD, 7mm width"), we can
        deterministically match to the exact type constant (e.g., BB608).

        Returns:
            DimensionalMatchResult if matcher is available, None otherwise
        """
        if not DIMENSIONAL_MATCHER_AVAILABLE:
            return None

        try:
            result = match_prompt_to_component(prompt)
            if result.has_match:
                bm = result.best_match
                print(f"[DimensionalMatcher] Matched: {bm.type_constant} "
                      f"(family={bm.component_family}, confidence={bm.confidence:.2f}, "
                      f"error={bm.dimension_error:.4f})")
                print(f"[DimensionalMatcher] SCAD: {bm.scad_call}")
            else:
                family = result.detected_family or "unknown"
                print(f"[DimensionalMatcher] No confident match for family={family}")
            return result
        except Exception as e:
            print(f"[DimensionalMatcher] Error: {e}")
            return None

    def analyze(self, prompt: str, original_prompt: str = None) -> DesignBrief:
        """
        Analyze a text prompt and create a design brief.

        Automatically detects and incorporates KB components if available.
        Uses component filtering to remove sub-parts and prioritize main components.
        Uses dimensional matching to find exact NopSCADlib type constants.
        RAG is purely additive - if KB fails, generation continues without it.

        Args:
            prompt: Natural language description of desired CAD model (may be enhanced)
            original_prompt: The user's original prompt (before enhancement).
                           Used to filter out hardware that wasn't explicitly requested.

        Returns:
            DesignBrief with extracted information and KB context
        """
        # Step 0: Try dimensional matching first (fast, deterministic)
        dim_match = self._try_dimensional_match(prompt)

        # Step 1: Try to detect KB components with filtering (safely)
        kb_contexts = []
        kb_context_str = ""
        has_kb = False
        filter_result = None

        if self.use_kb:
            try:
                detection, retrieval, kb_contexts, filter_result = self._detect_kb_components(
                    prompt, original_prompt=original_prompt
                )
                has_kb = len(kb_contexts) > 0
                if has_kb:
                    kb_context_str = self._build_kb_context_string(retrieval)
                    # Log with role information
                    comp_info = [f"{c.module_name}({c.role})" for c in kb_contexts]
                    print(f"[KB] Using {len(kb_contexts)} filtered components: {comp_info}")
            except Exception as e:
                print(f"[KB] Detection failed (continuing without KB): {e}")
                has_kb = False
                kb_contexts = []

        # Step 1.5: If dimensional matcher found a high-confidence match,
        # inject it as a KB component context (overrides text-based detection)
        if dim_match and dim_match.has_match:
            bm = dim_match.best_match
            # Build a KBComponentContext from the dimensional match
            dim_kb_ctx = KBComponentContext(
                component_id=bm.component_id,
                component_name=bm.type_constant,
                module_name=bm.module_function,
                module_code=(
                    f"include <NopSCADlib/lib.scad>\n\n"
                    f"// Matched by dimensional analysis: {bm.type_constant}\n"
                    f"// SCAD call: {bm.scad_call}\n"
                ),
                parameters=[],
                description=f"Dimensionally matched {bm.component_family}: {bm.type_constant}",
                confidence=bm.confidence,
                role="primary",
                priority=0,  # Highest priority (above all others)
                is_subpart=False,
            )
            # Store the exact SCAD call for the compiler to use
            dim_kb_ctx._dimensional_match = bm

            # Replace or prepend to KB contexts
            kb_contexts = [dim_kb_ctx] + [
                c for c in kb_contexts
                if c.module_name != bm.module_function
            ]
            has_kb = True
            print(f"[DimensionalMatcher] Injected {bm.type_constant} as primary KB component")

        # Step 2: Try LLM analysis (with KB if available, fallback to without KB)
        return self._analyze_with_fallback(prompt, has_kb, kb_contexts, kb_context_str, filter_result)

    def _analyze_with_fallback(
        self,
        prompt: str,
        has_kb: bool,
        kb_contexts: List[KBComponentContext],
        kb_context_str: str,
        filter_result: Optional['FilterResult'] = None
    ) -> DesignBrief:
        """
        Analyze prompt with automatic fallback.

        If KB-augmented analysis fails, retries without KB.
        If that fails, uses heuristic fallback.
        """
        # First attempt: with KB if available
        if has_kb:
            try:
                system_prompt = REASONER_KB_AUGMENTED_PROMPT.format(kb_context=kb_context_str)
                result = self._call_llm_analyze(prompt, system_prompt, kb_contexts, kb_context_str, True, filter_result)
                if result:
                    return result
            except Exception as e:
                print(f"[KB] Augmented analysis failed, retrying without KB: {e}")

        # Second attempt: without KB
        try:
            result = self._call_llm_analyze(prompt, REASONER_SYSTEM_PROMPT, [], "", False, None)
            if result:
                return result
        except Exception as e:
            print(f"[Reasoner] LLM analysis failed, using heuristic fallback: {e}")

        # Final fallback: heuristics
        return self._fallback_analysis(prompt, "", kb_contexts if has_kb else [], filter_result)

    def _call_llm_analyze(
        self,
        prompt: str,
        system_prompt: str,
        kb_contexts: List[KBComponentContext],
        kb_context_str: str,
        has_kb: bool,
        filter_result: Optional['FilterResult'] = None
    ) -> Optional[DesignBrief]:
        """Call LLM for analysis and parse response."""
        response = self.client.chat.completions.create(
            model=self.model,
            temperature=0.2,
            response_format={"type": "json_object"},
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": f"Analyze this CAD request: {prompt}"}
            ]
        )

        data = json.loads(response.choices[0].message.content)

        # Parse tiered parts
        essential_parts = data.get("essential_parts", [])
        secondary_parts = data.get("secondary_parts", [])
        optional_parts = data.get("optional_parts", [])

        # Build expected parts (all parts combined for backward compatibility)
        expected_parts = data.get("expected_parts", [])
        if not expected_parts:
            expected_parts = essential_parts + secondary_parts + optional_parts

        if has_kb:
            # Add KB module names to essential parts if not already present
            for kb_ctx in kb_contexts:
                if kb_ctx.module_name not in essential_parts:
                    essential_parts.append(kb_ctx.module_name)
                if kb_ctx.module_name not in expected_parts:
                    expected_parts.append(kb_ctx.module_name)

        # Extract assembly metadata from filter result
        is_assembly = False
        assembly_description = ""
        primary_component = None
        
        if filter_result:
            is_assembly = filter_result.is_assembly
            assembly_description = filter_result.assembly_description
            # Find primary component
            for fc in filter_result.filtered_components:
                if hasattr(fc.role, 'value'):
                    role_val = fc.role.value
                else:
                    role_val = str(fc.role)
                if role_val == "primary":
                    primary_component = fc.module_name
                    break

        return DesignBrief(
            description=data.get("brief", prompt),
            expected_parts=expected_parts,
            parameters=data.get("parameters", {"W": 100, "H": 100, "D": 100}),
            source="text",
            original_input=prompt,
            essential_parts=essential_parts,
            secondary_parts=secondary_parts,
            optional_parts=optional_parts,
            kb_components=kb_contexts,
            kb_augmented=has_kb,
            kb_context_prompt=kb_context_str,
            is_assembly=is_assembly,
            assembly_description=assembly_description,
            kb_primary_component=primary_component
        )

    def _fallback_analysis(
        self,
        prompt: str,
        error: str = "",
        kb_contexts: List[KBComponentContext] = None,
        filter_result: Optional['FilterResult'] = None
    ) -> DesignBrief:
        """
        Fallback analysis using heuristics when LLM fails.
        Still incorporates KB components if detected.
        """
        kb_contexts = kb_contexts or []
        parts = self._extract_parts_heuristic(prompt)
        params = self._estimate_parameters(prompt)

        # Add KB module names to parts
        for kb_ctx in kb_contexts:
            if kb_ctx.module_name not in parts:
                parts.append(kb_ctx.module_name)

        # Extract assembly metadata from filter result
        is_assembly = False
        assembly_description = ""
        primary_component = None
        
        if filter_result:
            is_assembly = filter_result.is_assembly
            assembly_description = filter_result.assembly_description
            for fc in filter_result.filtered_components:
                if hasattr(fc.role, 'value'):
                    role_val = fc.role.value
                else:
                    role_val = str(fc.role)
                if role_val == "primary":
                    primary_component = fc.module_name
                    break

        return DesignBrief(
            description=f"CAD model of: {prompt}" + (f" (LLM error: {error})" if error else ""),
            expected_parts=parts,
            parameters=params,
            source="text",
            original_input=prompt,
            kb_components=kb_contexts,
            kb_augmented=len(kb_contexts) > 0,
            kb_context_prompt="",
            is_assembly=is_assembly,
            assembly_description=assembly_description,
            kb_primary_component=primary_component
        )
    
    def _extract_parts_heuristic(self, prompt: str) -> List[str]:
        """
        Extract expected parts using keyword matching.
        """
        prompt_lower = prompt.lower()
        parts = []
        
        # Object-specific part mappings
        object_parts = {
            "car": ["body", "wheels", "axles", "windows"],
            "vehicle": ["body", "wheels", "axles"],
            "truck": ["body", "wheels", "axles", "cabin", "bed"],
            "mug": ["body", "handle", "base"],
            "cup": ["body", "handle", "base"],
            "bottle": ["body", "neck", "cap", "base"],
            "box": ["base", "walls", "top"],
            "container": ["base", "walls", "top"],
            "table": ["top", "legs"],
            "chair": ["seat", "back", "legs"],
            "desk": ["top", "legs", "drawers"],
            "house": ["walls", "roof", "door", "windows", "foundation"],
            "building": ["walls", "roof", "door", "windows"],
            "lamp": ["base", "stem", "shade"],
            "phone": ["body", "screen", "buttons"],
            "gear": ["body", "teeth", "hub"],
            "bracket": ["body", "mounting_holes", "flanges"],
            "pipe": ["body", "fittings"],
            "screw": ["head", "shaft", "threads"],
            "bolt": ["head", "shaft", "threads"],
            "nut": ["body", "threads", "flats"],
            "washer": ["body", "hole"],
            "bearing": ["outer_race", "inner_race", "balls"],
        }
        
        # Check for object types
        for obj_type, obj_parts in object_parts.items():
            if obj_type in prompt_lower:
                parts.extend(obj_parts)
                break
        
        # Check for explicitly mentioned parts
        explicit_parts = {
            "wheel": "wheels",
            "handle": "handle",
            "leg": "legs",
            "arm": "arms",
            "door": "door",
            "window": "windows",
            "hole": "holes",
            "slot": "slots",
            "groove": "grooves",
            "flange": "flanges",
            "base": "base",
            "top": "top",
            "lid": "lid",
            "cover": "cover",
            "shaft": "shaft",
            "hub": "hub",
            "rim": "rim",
            "spoke": "spokes",
            "tooth": "teeth",
        }
        
        for keyword, part_name in explicit_parts.items():
            if keyword in prompt_lower and part_name not in parts:
                parts.append(part_name)
        
        # Default if nothing found
        if not parts:
            parts = ["body"]
        
        return list(set(parts))  # Remove duplicates
    
    def _estimate_parameters(self, prompt: str) -> Dict[str, float]:
        """
        Estimate reasonable parameters based on object type.
        """
        prompt_lower = prompt.lower()
        
        # Default parameters
        params = {"W": 100, "H": 100, "D": 100}
        
        # Object-specific defaults (in mm)
        size_hints = {
            "car": {"W": 400, "H": 150, "D": 180, "wheel_r": 40},
            "truck": {"W": 500, "H": 200, "D": 200, "wheel_r": 50},
            "mug": {"W": 80, "H": 100, "D": 80, "handle_r": 15, "wall_t": 3},
            "cup": {"W": 70, "H": 90, "D": 70, "wall_t": 2},
            "bottle": {"W": 70, "H": 200, "D": 70, "neck_r": 15},
            "table": {"W": 1200, "H": 750, "D": 800, "leg_w": 50},
            "chair": {"W": 450, "H": 900, "D": 450, "seat_h": 450},
            "desk": {"W": 1400, "H": 750, "D": 700},
            "house": {"W": 8000, "H": 6000, "D": 10000, "wall_t": 200},
            "lamp": {"W": 150, "H": 400, "D": 150},
            "phone": {"W": 75, "H": 150, "D": 8},
            "gear": {"W": 50, "H": 10, "D": 50, "teeth": 20},
            "bracket": {"W": 80, "H": 60, "D": 40, "thickness": 5},
            "screw": {"W": 6, "H": 20, "D": 6},
            "bolt": {"W": 10, "H": 30, "D": 10},
            "nut": {"W": 15, "H": 8, "D": 15},
            "washer": {"W": 20, "H": 2, "D": 20},
            "bearing": {"W": 40, "H": 15, "D": 40},
            "box": {"W": 100, "H": 80, "D": 100, "wall_t": 3},
            "container": {"W": 150, "H": 100, "D": 150},
        }
        
        # Find matching object type
        for obj_type, obj_params in size_hints.items():
            if obj_type in prompt_lower:
                params.update(obj_params)
                break
        
        # Check for size modifiers
        if "small" in prompt_lower or "mini" in prompt_lower or "tiny" in prompt_lower:
            params = {k: v * 0.5 for k, v in params.items()}
        elif "large" in prompt_lower or "big" in prompt_lower:
            params = {k: v * 1.5 for k, v in params.items()}
        elif "huge" in prompt_lower or "giant" in prompt_lower:
            params = {k: v * 2.0 for k, v in params.items()}
        
        return params


# =============================================================================
# CONVENIENCE FUNCTION
# =============================================================================

def create_design_brief(
    client,
    prompt: str,
    model: str = "gpt-4o"
) -> DesignBrief:
    """
    Convenience function to create a design brief from a text prompt.
    
    Args:
        client: OpenAI client instance
        prompt: Natural language description
        model: Model to use
        
    Returns:
        DesignBrief instance
    """
    reasoner = TextReasoner(client, model)
    return reasoner.analyze(prompt)
