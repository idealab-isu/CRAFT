#!/usr/bin/env python3
"""
Compute objective complexity scores for NopSCADlib components.

Analyzes the source code of each component's NopSCADlib module to compute
measurable complexity metrics, then assigns a composite score and tier.

Metrics:
  - primitive_count:   Number of geometric primitives (cube, cylinder, sphere, etc.)
  - boolean_op_count:  Number of boolean operations (difference, union, intersection)
  - csg_depth:         Max nesting depth of boolean operations
  - parameter_count:   Number of fields in the type constant array
  - sub_module_calls:  Number of calls to other NopSCADlib modules
  - lines_of_code:     LOC of the module body
  - transform_count:   Number of transform operations (translate, rotate, scale, etc.)

Output: Adds complexity_score and tier to each component in the catalog.
"""

import json
import re
import sys
from pathlib import Path
from typing import Dict, List, Tuple

# ── paths ──────────────────────────────────────────────────────────
SCRIPT_DIR = Path(__file__).parent
REPO_ROOT = SCRIPT_DIR.parent.parent
GT_DIR = REPO_ROOT / "ground_truth" / "nopscadlib"
CATALOG_PATH = GT_DIR / "nopscadlib_component_catalog.json"
RENDER_RESULTS_PATH = GT_DIR / "render_results.json"
OUTPUT_PATH = GT_DIR / "benchmark_ground_truth.json"

CRAFT_DIR = REPO_ROOT / "pipeline"
NOPSCADLIB_DIR = CRAFT_DIR / "kb_data" / "nopscadlib"
VITAMINS_DIR = NOPSCADLIB_DIR / "vitamins"

# ── primitives and operations to count ─────────────────────────────
PRIMITIVES = [
    "cube", "cylinder", "sphere", "polyhedron", "polygon",
    "linear_extrude", "rotate_extrude", "circle", "square", "text",
    "import", "surface",
]

BOOLEAN_OPS = ["difference", "union", "intersection"]

TRANSFORMS = [
    "translate", "rotate", "scale", "mirror", "multmatrix",
    "color", "hull", "minkowski", "offset", "resize",
]


def count_pattern(content: str, names: List[str]) -> int:
    """Count occurrences of named OpenSCAD calls in content."""
    total = 0
    for name in names:
        # Match name followed by ( but not as part of a longer word
        pattern = rf'\b{re.escape(name)}\s*\('
        total += len(re.findall(pattern, content))
    return total


def compute_csg_depth(content: str) -> int:
    """Compute maximum nesting depth of boolean operations."""
    max_depth = 0
    current_depth = 0
    in_bool = False

    # Simple heuristic: track { } depth after boolean ops
    for i, ch in enumerate(content):
        if ch == '{':
            # Check if this brace follows a boolean op
            before = content[max(0, i - 50):i].strip()
            if any(before.endswith(op) or f"{op}(" in before[-30:]
                   for op in BOOLEAN_OPS):
                in_bool = True
            current_depth += 1
            if current_depth > max_depth:
                max_depth = current_depth
        elif ch == '}':
            current_depth -= 1

    return max_depth


def count_sub_modules(content: str, module_name: str) -> int:
    """Count calls to other modules (not self, not primitives/transforms)."""
    skip = set(PRIMITIVES + BOOLEAN_OPS + TRANSFORMS + [
        module_name, "assert", "echo", "let", "for", "if",
        "each", "render", "children", "$fn", "$fa", "$fs",
    ])

    # Find all function/module calls: name(
    calls = re.findall(r'\b([a-zA-Z_]\w*)\s*\(', content)
    sub_calls = [c for c in calls if c not in skip and not c.startswith('_')]

    # Deduplicate and count unique modules called
    return len(set(sub_calls))


def get_module_source(module_file: str, module_name: str) -> str:
    """Read the full module source code from the NopSCADlib file."""
    file_path = VITAMINS_DIR / module_file
    if not file_path.exists():
        return ""

    content = file_path.read_text(encoding='utf-8', errors='ignore')

    # Find the module definition
    pattern = rf'^module\s+{re.escape(module_name)}\s*\([^)]*\)\s*\{{'
    match = re.search(pattern, content, re.MULTILINE)
    if not match:
        return ""

    # Extract full module body by tracking braces
    start = match.start()
    brace_start = content.find('{', match.start())
    if brace_start == -1:
        return ""

    depth = 1
    pos = brace_start + 1
    while pos < len(content) and depth > 0:
        if content[pos] == '{':
            depth += 1
        elif content[pos] == '}':
            depth -= 1
        pos += 1

    return content[start:pos]


def compute_metrics(component: dict) -> Dict:
    """Compute all complexity metrics for a single component."""
    module_func = component["module_function"]
    module_file = component["module_file"]
    field_values = component.get("field_values", [])

    # Get module source
    source = get_module_source(module_file, module_func)

    # If no source found, use minimal metrics from the type constant
    if not source:
        return {
            "primitive_count": 0,
            "boolean_op_count": 0,
            "csg_depth": 0,
            "parameter_count": len(field_values),
            "sub_module_calls": 0,
            "lines_of_code": 0,
            "transform_count": 0,
            "complexity_score": len(field_values) * 0.5,
        }

    # Strip comments for cleaner counting
    stripped = re.sub(r'//[^\n]*', '', source)
    stripped = re.sub(r'/\*[\s\S]*?\*/', '', stripped)

    metrics = {
        "primitive_count": count_pattern(stripped, PRIMITIVES),
        "boolean_op_count": count_pattern(stripped, BOOLEAN_OPS),
        "csg_depth": compute_csg_depth(stripped),
        "parameter_count": len(field_values),
        "sub_module_calls": count_sub_modules(stripped, module_func),
        "lines_of_code": len([l for l in source.split('\n') if l.strip()]),
        "transform_count": count_pattern(stripped, TRANSFORMS),
    }

    # Composite complexity score (weighted sum, normalized roughly to 1-10)
    score = (
        metrics["primitive_count"] * 1.0 +
        metrics["boolean_op_count"] * 1.5 +
        metrics["csg_depth"] * 0.5 +
        metrics["parameter_count"] * 0.3 +
        metrics["sub_module_calls"] * 2.0 +
        metrics["lines_of_code"] * 0.05 +
        metrics["transform_count"] * 0.3
    )

    metrics["complexity_score"] = round(score, 2)
    return metrics


def assign_tiers(components: List[dict]) -> List[dict]:
    """Assign Simple/Medium/Complex tiers based on complexity score percentiles."""
    scores = [c["complexity_score"] for c in components]
    scores_sorted = sorted(scores)

    n = len(scores_sorted)
    # Use 33rd and 66th percentiles as boundaries
    p33 = scores_sorted[n // 3]
    p66 = scores_sorted[2 * n // 3]

    print(f"\nComplexity score distribution:")
    print(f"  Min:  {min(scores):.1f}")
    print(f"  P33:  {p33:.1f}  (Simple/Medium boundary)")
    print(f"  P66:  {p66:.1f}  (Medium/Complex boundary)")
    print(f"  Max:  {max(scores):.1f}")
    print(f"  Mean: {sum(scores)/len(scores):.1f}")

    for comp in components:
        s = comp["complexity_score"]
        if s <= p33:
            comp["tier"] = "Simple"
        elif s <= p66:
            comp["tier"] = "Medium"
        else:
            comp["tier"] = "Complex"

    # Count per tier
    tier_counts = {}
    for comp in components:
        tier_counts[comp["tier"]] = tier_counts.get(comp["tier"], 0) + 1

    print(f"\nTier distribution:")
    for tier in ["Simple", "Medium", "Complex"]:
        print(f"  {tier:10s}: {tier_counts.get(tier, 0)} components")

    return components


def main():
    print("=" * 60)
    print("NopSCADlib Complexity Scoring")
    print("=" * 60)

    # Load catalog
    with open(CATALOG_PATH) as f:
        catalog = json.load(f)

    # Load render results to only score successfully rendered components
    with open(RENDER_RESULTS_PATH) as f:
        render_data = json.load(f)

    success_names = {r["name"] for r in render_data["results"] if r["stl_ok"]}
    print(f"Successfully rendered: {len(success_names)} components")

    # Build lookup from catalog
    catalog_lookup = {}
    for comp in catalog["components"]:
        family = comp["component_family"]
        tc = comp["type_constant"]
        key = f"{family}__{tc}"
        catalog_lookup[key] = comp

    # Compute metrics for each rendered component
    scored = []
    for name in sorted(success_names):
        comp = catalog_lookup.get(name)
        if not comp:
            continue

        metrics = compute_metrics(comp)
        entry = {
            "id": name,
            "type_constant": comp["type_constant"],
            "module_function": comp["module_function"],
            "scad_call": comp["scad_call"],
            "component_family": comp["component_family"],
            "module_file": comp["module_file"],
            "category_file": comp["category_file"],
            "display_name": comp["display_name"],
            "description": comp["description"],
            "field_names": comp["field_names"],
            "field_values": comp["field_values"],
            "dimensions": comp["dimensions"],
            "scad_file": f"ground_truth/scad/{name}.scad",
            "stl_file": f"ground_truth/stl/{name}.stl",
            "png_file": f"ground_truth/png/{name}.png",
            **metrics,
        }
        scored.append(entry)

    print(f"\nScored {len(scored)} components")

    # Assign tiers
    scored = assign_tiers(scored)

    # Show examples per tier
    for tier in ["Simple", "Medium", "Complex"]:
        tier_comps = [c for c in scored if c["tier"] == tier]
        tier_comps.sort(key=lambda c: c["complexity_score"])
        print(f"\n{tier} examples (by score):")
        samples = tier_comps[:3] + tier_comps[-3:]
        for c in samples:
            print(f"  {c['complexity_score']:6.1f}  {c['id'][:50]}")

    # Save
    simple_scores = [c["complexity_score"] for c in scored if c["tier"] == "Simple"]
    medium_scores = [c["complexity_score"] for c in scored if c["tier"] == "Medium"]

    output = {
        "version": "1.0",
        "total": len(scored),
        "tier_boundaries": {
            "simple_max": max(simple_scores) if simple_scores else 0,
            "medium_max": max(medium_scores) if medium_scores else 0,
        },
        "components": scored,
    }

    with open(OUTPUT_PATH, 'w') as f:
        json.dump(output, f, indent=2)

    print(f"\nOutput saved to: {OUTPUT_PATH}")


if __name__ == "__main__":
    main()
