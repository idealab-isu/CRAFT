"""
Extended Test Prompts for CRAFT Paper Evaluation

Based on NopSCADlib components and common CAD objects.
Categories: Simple, Medium, Complex (for Table 8 single image performance)
Total: 30 prompts (expandable to 50-100)

Used for:
- Table 4: Main Results
- Table 5: Model Ablation
- Table 6: VLM Iteration Ablation
- Table 7: Verification Ablation
- Table 8: Single Image Performance by Complexity
"""

from typing import List, Dict, Any, Optional
from dataclasses import dataclass, asdict


@dataclass
class TestPrompt:
    """Test prompt with metadata for evaluation."""
    id: str
    text: str
    category: str  # simple, medium, complex
    complexity_score: int  # 1-10
    expected_parts: List[str]
    essential_parts: List[str]  # Must be present
    secondary_parts: List[str]  # Should be present
    optional_parts: List[str]  # Nice to have
    source: str  # nopscadlib, custom, mechanical

    def to_dict(self) -> Dict[str, Any]:
        return asdict(self)


# =============================================================================
# SIMPLE PROMPTS (Complexity 1-3)
# Single primitives or basic combinations
# =============================================================================

SIMPLE_PROMPTS = [
    TestPrompt(
        id="simple_01",
        text="A cube with 20mm sides",
        category="simple",
        complexity_score=1,
        expected_parts=["cube"],
        essential_parts=["cube"],
        secondary_parts=[],
        optional_parts=[],
        source="basic"
    ),
    TestPrompt(
        id="simple_02",
        text="A cylinder with radius 15mm and height 30mm",
        category="simple",
        complexity_score=1,
        expected_parts=["cylinder"],
        essential_parts=["cylinder"],
        secondary_parts=[],
        optional_parts=[],
        source="basic"
    ),
    TestPrompt(
        id="simple_03",
        text="A sphere with diameter 25mm",
        category="simple",
        complexity_score=1,
        expected_parts=["sphere"],
        essential_parts=["sphere"],
        secondary_parts=[],
        optional_parts=[],
        source="basic"
    ),
    TestPrompt(
        id="simple_04",
        text="A rectangular box 40mm x 20mm x 10mm",
        category="simple",
        complexity_score=1,
        expected_parts=["box"],
        essential_parts=["box"],
        secondary_parts=[],
        optional_parts=[],
        source="basic"
    ),
    TestPrompt(
        id="simple_05",
        text="A washer with 10mm outer diameter, 5mm inner hole, and 2mm thickness",
        category="simple",
        complexity_score=2,
        expected_parts=["washer", "hole"],
        essential_parts=["washer"],
        secondary_parts=["hole"],
        optional_parts=[],
        source="nopscadlib"
    ),
    TestPrompt(
        id="simple_06",
        text="A hollow cylinder with outer diameter 30mm, inner diameter 20mm, height 40mm",
        category="simple",
        complexity_score=2,
        expected_parts=["outer_cylinder", "inner_hole"],
        essential_parts=["outer_cylinder"],
        secondary_parts=["inner_hole"],
        optional_parts=[],
        source="basic"
    ),
    TestPrompt(
        id="simple_07",
        text="A cone with base radius 20mm and height 35mm",
        category="simple",
        complexity_score=1,
        expected_parts=["cone"],
        essential_parts=["cone"],
        secondary_parts=[],
        optional_parts=[],
        source="basic"
    ),
    TestPrompt(
        id="simple_08",
        text="A flat circular plate 50mm diameter and 3mm thick",
        category="simple",
        complexity_score=1,
        expected_parts=["plate"],
        essential_parts=["plate"],
        secondary_parts=[],
        optional_parts=[],
        source="basic"
    ),
    TestPrompt(
        id="simple_09",
        text="A rounded corner box 30mm x 30mm x 10mm with 3mm corner radius",
        category="simple",
        complexity_score=2,
        expected_parts=["box", "rounded_corners"],
        essential_parts=["box"],
        secondary_parts=["rounded_corners"],
        optional_parts=[],
        source="basic"
    ),
    TestPrompt(
        id="simple_10",
        text="A torus with major radius 20mm and minor radius 5mm",
        category="simple",
        complexity_score=2,
        expected_parts=["torus"],
        essential_parts=["torus"],
        secondary_parts=[],
        optional_parts=[],
        source="basic"
    ),
]

# =============================================================================
# MEDIUM PROMPTS (Complexity 4-6)
# Multi-part objects with clear structure
# =============================================================================

MEDIUM_PROMPTS = [
    TestPrompt(
        id="medium_01",
        text="A coffee mug with a handle on the right side",
        category="medium",
        complexity_score=4,
        expected_parts=["body", "handle", "cavity"],
        essential_parts=["body", "handle"],
        secondary_parts=["cavity"],
        optional_parts=[],
        source="custom"
    ),
    TestPrompt(
        id="medium_02",
        text="A simple table with 4 legs, 100mm wide tabletop",
        category="medium",
        complexity_score=4,
        expected_parts=["tabletop", "legs"],
        essential_parts=["tabletop", "legs"],
        secondary_parts=[],
        optional_parts=[],
        source="custom"
    ),
    TestPrompt(
        id="medium_03",
        text="A pulley wheel 40mm diameter with 8mm center bore and V-groove",
        category="medium",
        complexity_score=5,
        expected_parts=["wheel", "bore", "groove"],
        essential_parts=["wheel", "bore"],
        secondary_parts=["groove"],
        optional_parts=[],
        source="nopscadlib"
    ),
    TestPrompt(
        id="medium_04",
        text="A cable clip for 6mm diameter cable with mounting hole",
        category="medium",
        complexity_score=4,
        expected_parts=["clip_body", "cable_channel", "mounting_hole"],
        essential_parts=["clip_body", "cable_channel"],
        secondary_parts=["mounting_hole"],
        optional_parts=[],
        source="nopscadlib"
    ),
    TestPrompt(
        id="medium_05",
        text="A bearing housing for 608 bearing (22mm OD) with mounting flanges",
        category="medium",
        complexity_score=5,
        expected_parts=["housing", "bearing_bore", "flanges"],
        essential_parts=["housing", "bearing_bore"],
        secondary_parts=["flanges"],
        optional_parts=["mounting_holes"],
        source="nopscadlib"
    ),
    TestPrompt(
        id="medium_06",
        text="A knob 25mm diameter with knurled grip and M4 insert hole",
        category="medium",
        complexity_score=5,
        expected_parts=["knob_body", "knurling", "insert_hole"],
        essential_parts=["knob_body", "insert_hole"],
        secondary_parts=["knurling"],
        optional_parts=[],
        source="nopscadlib"
    ),
    TestPrompt(
        id="medium_07",
        text="A simple bracket L-shape 50mm x 30mm with 2 mounting holes",
        category="medium",
        complexity_score=4,
        expected_parts=["bracket", "holes"],
        essential_parts=["bracket"],
        secondary_parts=["holes"],
        optional_parts=[],
        source="mechanical"
    ),
    TestPrompt(
        id="medium_08",
        text="A pencil holder cylinder 80mm tall, 40mm outer diameter, 3mm wall thickness",
        category="medium",
        complexity_score=3,
        expected_parts=["outer_wall", "base", "cavity"],
        essential_parts=["outer_wall", "base"],
        secondary_parts=["cavity"],
        optional_parts=[],
        source="custom"
    ),
    TestPrompt(
        id="medium_09",
        text="A belt tensioner with pivot arm and spring mount",
        category="medium",
        complexity_score=6,
        expected_parts=["arm", "pivot", "spring_mount", "idler_mount"],
        essential_parts=["arm", "pivot"],
        secondary_parts=["spring_mount", "idler_mount"],
        optional_parts=[],
        source="nopscadlib"
    ),
    TestPrompt(
        id="medium_10",
        text="A fan guard 40mm with honeycomb pattern",
        category="medium",
        complexity_score=5,
        expected_parts=["frame", "guard_pattern", "mounting_holes"],
        essential_parts=["frame", "guard_pattern"],
        secondary_parts=["mounting_holes"],
        optional_parts=[],
        source="nopscadlib"
    ),
]

# =============================================================================
# COMPLEX PROMPTS (Complexity 7-10)
# Multi-component assemblies with intricate details
# =============================================================================

COMPLEX_PROMPTS = [
    TestPrompt(
        id="complex_01",
        text="A gear with 16 teeth, 40mm pitch diameter, 5mm thickness, 8mm center bore",
        category="complex",
        complexity_score=7,
        expected_parts=["hub", "teeth", "bore"],
        essential_parts=["hub", "teeth"],
        secondary_parts=["bore"],
        optional_parts=["chamfers"],
        source="mechanical"
    ),
    TestPrompt(
        id="complex_02",
        text="A phone stand with adjustable angle slot and cable routing hole",
        category="complex",
        complexity_score=6,
        expected_parts=["base", "support", "slot", "cable_hole"],
        essential_parts=["base", "support"],
        secondary_parts=["slot"],
        optional_parts=["cable_hole"],
        source="custom"
    ),
    TestPrompt(
        id="complex_03",
        text="A NEMA 17 stepper motor mount with 4 mounting holes and center bore",
        category="complex",
        complexity_score=7,
        expected_parts=["mount_plate", "mounting_holes", "center_bore", "relief_cutouts"],
        essential_parts=["mount_plate", "mounting_holes", "center_bore"],
        secondary_parts=["relief_cutouts"],
        optional_parts=[],
        source="nopscadlib"
    ),
    TestPrompt(
        id="complex_04",
        text="An electronics enclosure box 100x60x30mm with lid, ventilation slots, and cable gland hole",
        category="complex",
        complexity_score=8,
        expected_parts=["box", "lid", "ventilation_slots", "cable_hole"],
        essential_parts=["box", "lid"],
        secondary_parts=["ventilation_slots"],
        optional_parts=["cable_hole", "mounting_bosses"],
        source="nopscadlib"
    ),
    TestPrompt(
        id="complex_05",
        text="A shaft coupling for 5mm to 8mm shafts with set screw holes",
        category="complex",
        complexity_score=7,
        expected_parts=["body", "bore_5mm", "bore_8mm", "set_screw_holes"],
        essential_parts=["body", "bore_5mm", "bore_8mm"],
        secondary_parts=["set_screw_holes"],
        optional_parts=[],
        source="nopscadlib"
    ),
    TestPrompt(
        id="complex_06",
        text="A linear rail carriage block for MGN12 rail with bolt holes",
        category="complex",
        complexity_score=8,
        expected_parts=["block", "rail_channel", "bolt_holes", "ball_grooves"],
        essential_parts=["block", "rail_channel"],
        secondary_parts=["bolt_holes"],
        optional_parts=["ball_grooves"],
        source="nopscadlib"
    ),
    TestPrompt(
        id="complex_07",
        text="A hinge with two leaves, pin hole, and countersunk screw holes",
        category="complex",
        complexity_score=7,
        expected_parts=["leaf1", "leaf2", "pin_hole", "screw_holes", "knuckles"],
        essential_parts=["leaf1", "leaf2", "knuckles"],
        secondary_parts=["pin_hole", "screw_holes"],
        optional_parts=[],
        source="nopscadlib"
    ),
    TestPrompt(
        id="complex_08",
        text="A T-slot extrusion end cap 20x20mm with integrated spring clip",
        category="complex",
        complexity_score=7,
        expected_parts=["cap_body", "t_slot_profile", "spring_clip"],
        essential_parts=["cap_body", "t_slot_profile"],
        secondary_parts=["spring_clip"],
        optional_parts=[],
        source="nopscadlib"
    ),
    TestPrompt(
        id="complex_09",
        text="A drag chain link 15x20mm with snap-fit connectors",
        category="complex",
        complexity_score=8,
        expected_parts=["link_body", "male_connector", "female_connector", "cable_channel"],
        essential_parts=["link_body", "male_connector", "female_connector"],
        secondary_parts=["cable_channel"],
        optional_parts=[],
        source="nopscadlib"
    ),
    TestPrompt(
        id="complex_10",
        text="A gridfinity 1x1 bin 42mm with finger scoop and label slot",
        category="complex",
        complexity_score=7,
        expected_parts=["bin_body", "gridfinity_base", "finger_scoop", "label_slot"],
        essential_parts=["bin_body", "gridfinity_base"],
        secondary_parts=["finger_scoop"],
        optional_parts=["label_slot"],
        source="nopscadlib"
    ),
]


# =============================================================================
# Combined Dataset
# =============================================================================

ALL_PROMPTS: List[TestPrompt] = SIMPLE_PROMPTS + MEDIUM_PROMPTS + COMPLEX_PROMPTS


def get_prompts_by_category(category: str) -> List[TestPrompt]:
    """Get prompts for a specific category (simple/medium/complex)."""
    return [p for p in ALL_PROMPTS if p.category == category]


def get_prompts_by_complexity(min_score: int, max_score: int) -> List[TestPrompt]:
    """Get prompts within a complexity range."""
    return [p for p in ALL_PROMPTS if min_score <= p.complexity_score <= max_score]


def get_prompts_by_source(source: str) -> List[TestPrompt]:
    """Get prompts from a specific source (nopscadlib/custom/mechanical)."""
    return [p for p in ALL_PROMPTS if p.source == source]


def get_all_prompts() -> List[TestPrompt]:
    """Get all 30 prompts."""
    return ALL_PROMPTS.copy()


def get_prompts_subset(n: int, balanced: bool = True) -> List[TestPrompt]:
    """
    Get a subset of prompts.

    Args:
        n: Number of prompts to return
        balanced: If True, balance across categories
    """
    if not balanced:
        return ALL_PROMPTS[:n]

    # Get equal from each category
    per_category = n // 3
    remainder = n % 3

    result = []
    result.extend(SIMPLE_PROMPTS[:per_category + (1 if remainder > 0 else 0)])
    result.extend(MEDIUM_PROMPTS[:per_category + (1 if remainder > 1 else 0)])
    result.extend(COMPLEX_PROMPTS[:per_category])

    return result[:n]


def get_prompts_for_table(table_num: int, **kwargs) -> List[TestPrompt]:
    """
    Get prompts configured for specific paper table.

    Args:
        table_num: Table number (4, 5, 6, 7, or 8)
        **kwargs: Additional configuration
    """
    if table_num == 4:
        # Main results - all 30 prompts
        return get_all_prompts()

    elif table_num == 5:
        # Model ablation - balanced subset
        return get_prompts_subset(kwargs.get('n', 30), balanced=True)

    elif table_num == 6:
        # VLM iteration ablation - medium/complex only (need correction)
        return get_prompts_by_category("medium") + get_prompts_by_category("complex")

    elif table_num == 7:
        # Verification ablation - need prompts with tiered parts
        # Filter to prompts with secondary/optional parts
        return [p for p in ALL_PROMPTS if len(p.secondary_parts) > 0 or len(p.optional_parts) > 0]

    elif table_num == 8:
        # Single image by complexity - all prompts grouped
        return get_all_prompts()

    return get_all_prompts()


# For backwards compatibility with existing code
TEST_PROMPTS = {
    "simple": [p.to_dict() for p in SIMPLE_PROMPTS],
    "medium": [p.to_dict() for p in MEDIUM_PROMPTS],
    "complex": [p.to_dict() for p in COMPLEX_PROMPTS],
}


if __name__ == "__main__":
    print("CRAFT Paper Test Prompts")
    print("=" * 60)
    print(f"Total prompts: {len(ALL_PROMPTS)}")
    print(f"  Simple:  {len(SIMPLE_PROMPTS)}")
    print(f"  Medium:  {len(MEDIUM_PROMPTS)}")
    print(f"  Complex: {len(COMPLEX_PROMPTS)}")
    print()

    print("By Source:")
    for source in ["basic", "nopscadlib", "custom", "mechanical"]:
        count = len(get_prompts_by_source(source))
        print(f"  {source}: {count}")
    print()

    print("Sample prompts:")
    for p in [SIMPLE_PROMPTS[0], MEDIUM_PROMPTS[0], COMPLEX_PROMPTS[0]]:
        print(f"  [{p.category}] {p.id}: {p.text[:50]}...")
