"""
Component Filter for KB-detected components.

Filters and prioritizes detected KB components:
- Identifies primary vs secondary vs sub-part components
- Removes internal sub-parts that are already included by parent modules
- Assigns roles and priorities for assembly generation

Also integrates dimensional matching to select the exact type constant
when dimensions are provided in the prompt.
"""

from enum import Enum
from dataclasses import dataclass, field
from typing import List, Dict, Optional, Any


class ComponentRole(Enum):
    """Role of a component in an assembly."""
    PRIMARY = "primary"
    SECONDARY = "secondary"
    ATTACHMENT = "attachment"
    SUBPART = "subpart"
    HELPER = "helper"


@dataclass
class FilteredComponent:
    """A component after filtering with role/priority."""
    component_id: str
    module_name: str
    role: ComponentRole
    priority: int = 1           # 1 = highest
    parent_id: Optional[str] = None
    reason: str = ""


@dataclass
class FilterResult:
    """Result of component filtering."""
    filtered_components: List[FilteredComponent] = field(default_factory=list)
    removed_subparts: List[FilteredComponent] = field(default_factory=list)
    is_assembly: bool = False
    assembly_description: str = ""


# Known sub-part modules that are always included by parent modules
ALWAYS_SUBPART_MODULES = {
    "screw",
    "washer",
    "nut",
    "insert",
    "o_ring",
    "spring",
    "wire",
}

# Parent → child relationships (child is auto-included by parent)
PARENT_CHILD_MAP = {
    "stepper_motor": ["screw", "washer"],
    "scs_bearing_block": ["linear_bearing", "screw"],
    "hot_end": ["fan", "heatsink"],
    "extruder": ["stepper_motor", "gear", "hot_end"],
}

# Patterns that suggest a module is a sub-part
SUBPART_PATTERNS = [
    r"_screw$",
    r"_washer$",
    r"_nut$",
    r"_bolt$",
    r"_insert$",
    r"_o_ring$",
]


class ComponentFilter:
    """Filters and prioritizes KB components."""

    def __init__(self):
        pass

    def filter_components(
        self,
        detected_components: List[Any],
        prompt: str = "",
        original_prompt: str = ""
    ) -> FilterResult:
        """
        Filter detected components to remove sub-parts and assign roles.

        Args:
            detected_components: List of KBComponentContext objects
            prompt: The working prompt
            original_prompt: User's original prompt

        Returns:
            FilterResult with filtered components and removed sub-parts
        """
        if not detected_components:
            return FilterResult()

        # If only one component, it's the primary
        if len(detected_components) == 1:
            comp = detected_components[0]
            return FilterResult(
                filtered_components=[
                    FilteredComponent(
                        component_id=comp.component_id,
                        module_name=comp.module_name,
                        role=ComponentRole.PRIMARY,
                        priority=1,
                        reason="Only detected component"
                    )
                ],
                is_assembly=False
            )

        # Multiple components: identify roles
        filtered = []
        removed = []

        # Sort by confidence (highest first)
        sorted_comps = sorted(
            detected_components,
            key=lambda c: c.confidence,
            reverse=True
        )

        for i, comp in enumerate(sorted_comps):
            module_lower = comp.module_name.lower()

            # Check if this is a known sub-part
            is_subpart = module_lower in ALWAYS_SUBPART_MODULES

            # Check parent-child relationships
            parent_id = None
            for parent_mod, children in PARENT_CHILD_MAP.items():
                if module_lower in children:
                    # Check if parent is in the detected set
                    parent_detected = any(
                        c.module_name.lower() == parent_mod
                        for c in sorted_comps
                    )
                    if parent_detected:
                        is_subpart = True
                        parent_id = parent_mod
                        break

            if is_subpart:
                removed.append(FilteredComponent(
                    component_id=comp.component_id,
                    module_name=comp.module_name,
                    role=ComponentRole.SUBPART,
                    priority=99,
                    parent_id=parent_id,
                    reason=f"Sub-part of {parent_id or 'parent module'}"
                ))
            else:
                role = ComponentRole.PRIMARY if i == 0 else ComponentRole.SECONDARY
                filtered.append(FilteredComponent(
                    component_id=comp.component_id,
                    module_name=comp.module_name,
                    role=role,
                    priority=i + 1,
                    reason=f"Confidence: {comp.confidence:.2f}"
                ))

        is_assembly = len(filtered) > 1
        assembly_desc = ""
        if is_assembly:
            names = [f.module_name for f in filtered]
            assembly_desc = f"Assembly of {', '.join(names)}"

        return FilterResult(
            filtered_components=filtered,
            removed_subparts=removed,
            is_assembly=is_assembly,
            assembly_description=assembly_desc
        )


class AssemblyAnalyzer:
    """Analyzes whether detected components form an assembly."""

    def __init__(self):
        self.filter = ComponentFilter()

    def analyze(
        self,
        detected_components: List[Any],
        prompt: str = ""
    ) -> FilterResult:
        """Analyze components and determine assembly structure."""
        return self.filter.filter_components(
            detected_components, prompt=prompt
        )


# =============================================================================
# CONVENIENCE FUNCTIONS
# =============================================================================

def filter_detected_components(
    detected_components: List[Any],
    prompt: str = "",
    original_prompt: str = ""
) -> FilterResult:
    """
    Convenience function to filter detected components.

    Args:
        detected_components: List of KBComponentContext objects
        prompt: Working prompt
        original_prompt: Original user prompt

    Returns:
        FilterResult
    """
    cf = ComponentFilter()
    return cf.filter_components(
        detected_components,
        prompt=prompt,
        original_prompt=original_prompt
    )


def analyze_and_filter(
    prompt: str,
    detected_components: List[Any],
    client: Any = None,
    model: str = "gpt-4o-mini",
    original_prompt: str = ""
) -> FilterResult:
    """
    Analyze and filter detected KB components.

    This is the main entry point called by reasoner.py.
    The client/model params are accepted for API compatibility
    but filtering is done deterministically (no LLM needed).

    Args:
        prompt: Working prompt
        detected_components: List of KBComponentContext objects
        client: OpenAI client (unused, kept for API compatibility)
        model: Model name (unused)
        original_prompt: Original user prompt

    Returns:
        FilterResult with filtered and prioritized components
    """
    return filter_detected_components(
        detected_components,
        prompt=prompt,
        original_prompt=original_prompt
    )
