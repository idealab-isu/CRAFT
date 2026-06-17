"""
CRAFT Test Prompts

Categorized test prompts for evaluation.
Categories: Simple, Medium, Complex, With Dimensions, RAG (mechanical parts)
"""

from typing import List, Dict, Any

TEST_PROMPTS: Dict[str, List[Dict[str, Any]]] = {
    "simple": [
        {"id": "simple_01", "text": "A cube with 20mm sides", "expected_parts": ["cube"]},
        {"id": "simple_02", "text": "A cylinder with radius 15mm and height 30mm", "expected_parts": ["cylinder"]},
        {"id": "simple_03", "text": "A sphere with diameter 25mm", "expected_parts": ["sphere"]},
        {"id": "simple_04", "text": "A rectangular box 40mm x 20mm x 10mm", "expected_parts": ["box"]},
        {"id": "simple_05", "text": "A cone with base radius 20mm and height 40mm", "expected_parts": ["cone"]},
    ],

    "medium": [
        {"id": "medium_01", "text": "A coffee mug with a handle on the right side", "expected_parts": ["body", "handle"]},
        {"id": "medium_02", "text": "A simple table with 4 legs, 100mm wide tabletop", "expected_parts": ["tabletop", "legs"]},
        {"id": "medium_03", "text": "A drinking glass with a thick base", "expected_parts": ["body", "base"]},
        {"id": "medium_04", "text": "A simple chair with 4 legs and a backrest", "expected_parts": ["seat", "legs", "backrest"]},
        {"id": "medium_05", "text": "A pencil holder cylinder with thick walls, open top", "expected_parts": ["outer_wall", "base"]},
    ],

    "complex": [
        {"id": "complex_01", "text": "A gear with 12 teeth and 40mm outer diameter", "expected_parts": ["hub", "teeth"]},
        {"id": "complex_02", "text": "A phone stand with adjustable angle slot", "expected_parts": ["base", "support", "slot"]},
        {"id": "complex_03", "text": "A small house with pitched roof and front door", "expected_parts": ["walls", "roof", "door"]},
        {"id": "complex_04", "text": "A bracket with 2 mounting holes", "expected_parts": ["bracket", "holes"]},
        {"id": "complex_05", "text": "A toy car with 4 wheels and cabin", "expected_parts": ["body", "wheels", "cabin"]},
    ],

    "with_dimensions": [
        {"id": "dim_01", "text": "A rectangular box 100mm x 50mm x 30mm", "expected_parts": ["box"]},
        {"id": "dim_02", "text": "A cylinder 80mm tall with 25mm radius", "expected_parts": ["cylinder"]},
        {"id": "dim_03", "text": "A hollow cube with 50mm outer size and 5mm wall thickness", "expected_parts": ["outer", "inner"]},
        {"id": "dim_04", "text": "A pipe segment 60mm long, outer diameter 30mm, inner diameter 20mm", "expected_parts": ["pipe"]},
        {"id": "dim_05", "text": "A plate 120mm x 80mm x 3mm with rounded corners", "expected_parts": ["plate"]},
    ],

    "mechanical": [
        {"id": "mech_01", "text": "A hex nut M8 size", "expected_parts": ["nut", "threads"]},
        {"id": "mech_02", "text": "A washer with 10mm outer diameter and 5mm inner hole", "expected_parts": ["washer"]},
        {"id": "mech_03", "text": "A simple bearing housing 30mm diameter", "expected_parts": ["housing", "bore"]},
        {"id": "mech_04", "text": "A T-slot bracket 50mm long", "expected_parts": ["bracket", "slot"]},
        {"id": "mech_05", "text": "A pulley wheel 40mm diameter with center bore", "expected_parts": ["wheel", "bore"]},
    ],
}


def get_prompts_by_category(category: str) -> List[Dict[str, Any]]:
    """Get prompts for a specific category."""
    return TEST_PROMPTS.get(category, [])


def get_all_prompts() -> List[Dict[str, Any]]:
    """Get all prompts as a flat list with category info."""
    all_prompts = []
    for category, prompts in TEST_PROMPTS.items():
        for prompt in prompts:
            prompt_with_cat = prompt.copy()
            prompt_with_cat["category"] = category
            all_prompts.append(prompt_with_cat)
    return all_prompts


def get_prompts_subset(n: int = 15) -> List[Dict[str, Any]]:
    """Get a balanced subset of prompts (3 from each category)."""
    subset = []
    per_category = max(1, n // len(TEST_PROMPTS))

    for category, prompts in TEST_PROMPTS.items():
        for prompt in prompts[:per_category]:
            prompt_with_cat = prompt.copy()
            prompt_with_cat["category"] = category
            subset.append(prompt_with_cat)

    return subset[:n]
