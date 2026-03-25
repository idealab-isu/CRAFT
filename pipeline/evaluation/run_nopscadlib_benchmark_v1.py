#!/usr/bin/env python3
"""
NopSCADlib Ground Truth Benchmark Evaluation
V1: Generic prompts, basic pipeline (no VLM/verification)

This version uses generic CAD prompts without NopSCADlib-specific keywords.
The prompts describe common mechanical/engineering parts using plain language
rather than referencing specific NopSCADlib component names or aliases.

The CADence pipeline methods use the basic pipeline only:
  reasoner -> planner -> compiler -> save/render
No VLM self-correction or component verification is performed.
This establishes a baseline for how well the core pipeline performs
before adding visual feedback loops or structural verification.

Methods evaluated:
1. GPT-4o (direct) - Simple prompt -> code, NO pipeline
2. GPT-5.2 (direct) - Simple prompt -> code, NO pipeline
3. CADence (no RAG) - Basic pipeline (reasoner+planner+compiler), NO VLM, NO verification
4. CADence + RAG - Basic pipeline + NopSCADlib KB, NO VLM, NO verification

Usage:
    python run_nopscadlib_benchmark_v1.py
    python run_nopscadlib_benchmark_v1.py --quick  # Run only 3 prompts
    python run_nopscadlib_benchmark_v1.py --methods gpt4o cadence_rag
"""

import os
import sys
import json
import time
import argparse
import subprocess
from pathlib import Path
from datetime import datetime
from dataclasses import dataclass, asdict, field
from typing import Dict, List, Any, Optional, Tuple
import numpy as np

# Add parent paths
sys.path.insert(0, str(Path(__file__).parent.parent))
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

from dotenv import load_dotenv
load_dotenv()

from openai import OpenAI


# =============================================================================
# GENERIC BENCHMARK PROMPTS
# Plain-language CAD descriptions without NopSCADlib-specific keywords
# =============================================================================

@dataclass
class BenchmarkPrompt:
    """Benchmark prompt with ground truth OpenSCAD code."""
    id: str
    text: str                       # Natural language prompt (generic)
    category: str                   # simple, medium, complex
    ground_truth_scad: str          # Reference OpenSCAD code
    expected_parts: List[str]
    essential_parts: List[str]      # Must have
    secondary_parts: List[str]      # Should have
    optional_parts: List[str]       # Nice to have


# =============================================================================
# SIMPLE PROMPTS (5) - Basic geometric shapes
# =============================================================================

SIMPLE_PROMPTS = [
    BenchmarkPrompt(
        id="bench_simple_01",
        text="A cube with 20mm sides",
        category="simple",
        ground_truth_scad="""// Cube with 20mm sides
cube([20, 20, 20], center=true);
""",
        expected_parts=["cube"],
        essential_parts=["cube"],
        secondary_parts=[],
        optional_parts=[]
    ),
    BenchmarkPrompt(
        id="bench_simple_02",
        text="A cylinder with radius 15mm and height 30mm",
        category="simple",
        ground_truth_scad="""// Cylinder with radius 15mm, height 30mm
cylinder(r=15, h=30, center=true, $fn=64);
""",
        expected_parts=["cylinder"],
        essential_parts=["cylinder"],
        secondary_parts=[],
        optional_parts=[]
    ),
    BenchmarkPrompt(
        id="bench_simple_03",
        text="A sphere with diameter 25mm",
        category="simple",
        ground_truth_scad="""// Sphere with diameter 25mm (radius 12.5mm)
sphere(r=12.5, $fn=64);
""",
        expected_parts=["sphere"],
        essential_parts=["sphere"],
        secondary_parts=[],
        optional_parts=[]
    ),
    BenchmarkPrompt(
        id="bench_simple_04",
        text="A washer with 10mm outer diameter, 5mm inner hole, and 2mm thickness",
        category="simple",
        ground_truth_scad="""// Washer: OD=10mm, ID=5mm, thickness=2mm
washer_od = 10;
washer_id = 5;
washer_h = 2;

difference() {
    // Outer disc
    cylinder(d=washer_od, h=washer_h, center=true, $fn=64);
    // Inner hole
    cylinder(d=washer_id, h=washer_h + 1, center=true, $fn=64);
}
""",
        expected_parts=["outer_disc", "inner_hole"],
        essential_parts=["outer_disc", "inner_hole"],
        secondary_parts=[],
        optional_parts=[]
    ),
    BenchmarkPrompt(
        id="bench_simple_05",
        text="A hollow cylinder with outer diameter 30mm, inner diameter 20mm, height 40mm",
        category="simple",
        ground_truth_scad="""// Hollow cylinder: OD=30mm, ID=20mm, H=40mm
outer_d = 30;
inner_d = 20;
height = 40;

difference() {
    // Outer cylinder
    cylinder(d=outer_d, h=height, center=true, $fn=64);
    // Inner bore
    cylinder(d=inner_d, h=height + 1, center=true, $fn=64);
}
""",
        expected_parts=["outer_cylinder", "inner_bore"],
        essential_parts=["outer_cylinder", "inner_bore"],
        secondary_parts=[],
        optional_parts=[]
    ),
]


# =============================================================================
# MEDIUM PROMPTS (5) - Multi-feature mechanical parts
# =============================================================================

MEDIUM_PROMPTS = [
    BenchmarkPrompt(
        id="bench_medium_01",
        text="A pulley wheel 40mm diameter with 8mm center bore",
        category="medium",
        ground_truth_scad="""// Pulley wheel: 40mm diameter, 8mm bore, V-groove
pulley_d = 40;
bore_d = 8;
pulley_h = 10;
groove_depth = 3;
flange_extra = 2;

difference() {
    union() {
        // Main pulley body
        cylinder(d=pulley_d, h=pulley_h, center=true, $fn=64);

        // Top flange
        translate([0, 0, pulley_h/2 - 1])
            cylinder(d=pulley_d + flange_extra*2, h=1, $fn=64);

        // Bottom flange
        translate([0, 0, -pulley_h/2])
            cylinder(d=pulley_d + flange_extra*2, h=1, $fn=64);
    }

    // V-groove around circumference (approximated as torus cut)
    rotate_extrude($fn=64)
        translate([pulley_d/2, 0, 0])
            circle(r=groove_depth, $fn=32);

    // Center bore
    cylinder(d=bore_d, h=pulley_h + 10, center=true, $fn=64);
}
""",
        expected_parts=["pulley_body", "bore", "groove", "flanges"],
        essential_parts=["pulley_body", "bore"],
        secondary_parts=["groove", "flanges"],
        optional_parts=[]
    ),
    BenchmarkPrompt(
        id="bench_medium_02",
        text="A bearing housing for 608 bearing (22mm OD, 8mm bore)",
        category="medium",
        ground_truth_scad="""// Bearing housing for 608 bearing
// 608 bearing: OD=22mm, ID=8mm, H=7mm
bearing_od = 22;
bearing_id = 8;
bearing_h = 7;
wall = 3;
flange_width = 12;
flange_thickness = 4;
mount_hole_d = 4.2;

difference() {
    union() {
        // Main cylindrical housing
        cylinder(d=bearing_od + wall*2, h=bearing_h + 2, center=true, $fn=64);

        // Mounting flanges (two sides)
        for (a = [0, 180]) {
            rotate([0, 0, a])
                translate([bearing_od/2 + flange_width/2, 0, 0])
                    cube([flange_width, 16, flange_thickness], center=true);
        }
    }

    // Bearing pocket (press-fit)
    cylinder(d=bearing_od - 0.1, h=bearing_h, center=true, $fn=64);

    // Through bore for shaft
    cylinder(d=bearing_id, h=bearing_h + 10, center=true, $fn=64);

    // Mounting holes in flanges
    for (a = [0, 180]) {
        rotate([0, 0, a])
            translate([bearing_od/2 + flange_width/2, 0, 0])
                cylinder(d=mount_hole_d, h=flange_thickness + 1, center=true, $fn=32);
    }
}
""",
        expected_parts=["housing", "bearing_pocket", "bore", "flanges", "mounting_holes"],
        essential_parts=["housing", "bearing_pocket", "bore"],
        secondary_parts=["flanges", "mounting_holes"],
        optional_parts=[]
    ),
    BenchmarkPrompt(
        id="bench_medium_03",
        text="A simple L-bracket 50mm x 30mm with 2 mounting holes",
        category="medium",
        ground_truth_scad="""// L-bracket: 50mm vertical x 30mm horizontal
bracket_height = 50;
bracket_base = 30;
bracket_width = 20;
thickness = 3;
hole_d = 5;

difference() {
    union() {
        // Vertical arm
        translate([0, 0, bracket_height/2])
            cube([bracket_width, thickness, bracket_height], center=true);

        // Horizontal arm
        translate([0, bracket_base/2 - thickness/2, 0])
            cube([bracket_width, bracket_base, thickness], center=true);
    }

    // Mounting hole in vertical arm
    translate([0, 0, bracket_height - 10])
        rotate([90, 0, 0])
            cylinder(d=hole_d, h=thickness + 2, center=true, $fn=32);

    // Mounting hole in horizontal arm
    translate([0, bracket_base - thickness - 8, 0])
        cylinder(d=hole_d, h=thickness + 2, center=true, $fn=32);
}
""",
        expected_parts=["vertical_arm", "horizontal_arm", "mounting_holes"],
        essential_parts=["vertical_arm", "horizontal_arm", "mounting_holes"],
        secondary_parts=[],
        optional_parts=[]
    ),
    BenchmarkPrompt(
        id="bench_medium_04",
        text="A cable clip for 6mm diameter cable with mounting hole",
        category="medium",
        ground_truth_scad="""// Cable clip for 6mm cable with mounting hole
cable_d = 6;
wall = 2;
clip_width = 12;
base_length = 18;
base_thickness = 3;
mount_hole_d = 3.5;

difference() {
    union() {
        // Base plate
        cube([base_length, clip_width, base_thickness], center=true);

        // Cable channel (half-cylinder wrap)
        translate([base_length/2 - cable_d/2 - wall, 0, base_thickness/2 + cable_d/2])
            difference() {
                cylinder(d=cable_d + wall*2, h=clip_width, center=true, $fn=64);
                // Open top slot for snap-in
                translate([0, 0, 0])
                    cube([cable_d - 1, cable_d + wall*2 + 1, clip_width + 1], center=true);
            }
    }

    // Cable channel bore
    translate([base_length/2 - cable_d/2 - wall, 0, base_thickness/2 + cable_d/2])
        cylinder(d=cable_d, h=clip_width + 1, center=true, $fn=64);

    // Mounting hole in base
    translate([-base_length/2 + 5, 0, 0])
        cylinder(d=mount_hole_d, h=base_thickness + 1, center=true, $fn=32);
}
""",
        expected_parts=["base", "cable_channel", "mounting_hole"],
        essential_parts=["base", "cable_channel"],
        secondary_parts=["mounting_hole"],
        optional_parts=[]
    ),
    BenchmarkPrompt(
        id="bench_medium_05",
        text="A knob 25mm diameter with M4 insert hole",
        category="medium",
        ground_truth_scad="""// Knob: 25mm diameter with grip ridges and M4 insert
knob_d = 25;
knob_h = 15;
insert_d = 4;  // M4
insert_depth = 10;
n_ridges = 12;
ridge_depth = 1.5;

difference() {
    union() {
        // Main knob body (slightly domed top)
        cylinder(d=knob_d, h=knob_h - 2, center=false, $fn=64);

        // Dome top
        translate([0, 0, knob_h - 2])
            resize([knob_d, knob_d, 4])
                sphere(d=knob_d, $fn=64);
    }

    // Grip ridges around circumference
    for (i = [0:n_ridges-1]) {
        rotate([0, 0, i * 360/n_ridges])
            translate([knob_d/2, 0, knob_h/2])
                cylinder(d=ridge_depth*2, h=knob_h + 2, center=true, $fn=16);
    }

    // M4 insert hole from bottom
    cylinder(d=insert_d, h=insert_depth, center=false, $fn=32);

    // Wider entry chamfer
    cylinder(d1=insert_d + 2, d2=insert_d, h=2, center=false, $fn=32);
}
""",
        expected_parts=["knob_body", "ridges", "insert_hole"],
        essential_parts=["knob_body", "insert_hole"],
        secondary_parts=["ridges"],
        optional_parts=[]
    ),
]


# =============================================================================
# COMPLEX PROMPTS (5) - Advanced multi-component parts
# =============================================================================

COMPLEX_PROMPTS = [
    BenchmarkPrompt(
        id="bench_complex_01",
        text="A gear with 16 teeth, 40mm pitch diameter, 5mm thickness, 8mm center bore",
        category="complex",
        ground_truth_scad="""// Gear: 16 teeth, 40mm pitch diameter, 5mm thick, 8mm bore
n_teeth = 16;
pitch_d = 40;
gear_h = 5;
bore_d = 8;
module_val = pitch_d / n_teeth;  // 2.5mm module
addendum = module_val;
dedendum = module_val * 1.25;
outer_d = pitch_d + 2 * addendum;
root_d = pitch_d - 2 * dedendum;
tooth_angle = 360 / n_teeth;

difference() {
    union() {
        // Gear body with teeth
        linear_extrude(height=gear_h, center=true) {
            difference() {
                // Outer circle (tip)
                circle(d=outer_d, $fn=64);
                // Remove material between teeth
                for (i = [0:n_teeth-1]) {
                    rotate([0, 0, i * tooth_angle + tooth_angle/4])
                        translate([pitch_d/2, 0])
                            circle(d=module_val * 1.5, $fn=16);
                }
            }
        }

        // Hub
        cylinder(d=bore_d + 6, h=gear_h + 2, center=true, $fn=64);
    }

    // Center bore
    cylinder(d=bore_d, h=gear_h + 10, center=true, $fn=64);

    // Lightening holes
    for (i = [0:3]) {
        rotate([0, 0, i * 90 + 22.5])
            translate([pitch_d/4, 0, 0])
                cylinder(d=6, h=gear_h + 10, center=true, $fn=32);
    }

    // Keyway
    translate([bore_d/2 - 0.5, 0, 0])
        cube([2, 2, gear_h + 10], center=true);
}
""",
        expected_parts=["gear_body", "teeth", "bore", "hub", "lightening_holes"],
        essential_parts=["gear_body", "teeth", "bore"],
        secondary_parts=["hub", "lightening_holes"],
        optional_parts=["keyway"]
    ),
    BenchmarkPrompt(
        id="bench_complex_02",
        text="A NEMA 17 stepper motor mount with 4 mounting holes and center bore",
        category="complex",
        ground_truth_scad="""// NEMA 17 Stepper Motor Mount
// NEMA 17: 42.3mm face, 31mm hole pattern, 22mm boss
nema_size = 42.3;
hole_spacing = 31;
center_bore_d = 22;
plate_thickness = 4;
flange = 8;
mount_hole_d = 3.2;  // M3 clearance
corner_relief_d = 6;

difference() {
    // Main mounting plate
    cube([nema_size + flange*2, nema_size + flange*2, plate_thickness], center=true);

    // Center bore for shaft/boss clearance
    cylinder(d=center_bore_d, h=plate_thickness + 1, center=true, $fn=64);

    // 4 mounting holes in 31mm square pattern
    for (x = [-1, 1]) {
        for (y = [-1, 1]) {
            translate([x * hole_spacing/2, y * hole_spacing/2, 0])
                cylinder(d=mount_hole_d, h=plate_thickness + 1, center=true, $fn=32);
        }
    }

    // Corner reliefs (stress relief at motor face corners)
    for (x = [-1, 1]) {
        for (y = [-1, 1]) {
            translate([x * nema_size/2, y * nema_size/2, 0])
                cylinder(d=corner_relief_d, h=plate_thickness + 1, center=true, $fn=32);
        }
    }

    // Chamfered corners of plate
    for (x = [-1, 1]) {
        for (y = [-1, 1]) {
            translate([x * (nema_size/2 + flange), y * (nema_size/2 + flange), 0])
                rotate([0, 0, 45])
                    cube([flange, flange, plate_thickness + 1], center=true);
        }
    }
}
""",
        expected_parts=["plate", "center_bore", "mounting_holes", "corner_reliefs"],
        essential_parts=["plate", "center_bore", "mounting_holes"],
        secondary_parts=["corner_reliefs"],
        optional_parts=["chamfers"]
    ),
    BenchmarkPrompt(
        id="bench_complex_03",
        text="A shaft coupling for 5mm to 8mm shafts with set screw holes",
        category="complex",
        ground_truth_scad="""// Shaft Coupling: 5mm to 8mm with set screws and flex slots
shaft_small = 5;
shaft_large = 8;
coupling_od = 20;
coupling_length = 25;
set_screw_d = 3;  // M3 set screw
n_flex_slots = 4;

difference() {
    // Main coupling body
    cylinder(d=coupling_od, h=coupling_length, center=true, $fn=64);

    // 5mm shaft bore (bottom half)
    translate([0, 0, -coupling_length/4])
        cylinder(d=shaft_small, h=coupling_length/2 + 1, center=true, $fn=64);

    // 8mm shaft bore (top half)
    translate([0, 0, coupling_length/4])
        cylinder(d=shaft_large, h=coupling_length/2 + 1, center=true, $fn=64);

    // Flex slots (helical-style, approximated as horizontal cuts)
    for (i = [0:n_flex_slots-1]) {
        rotate([0, 0, i * 90])
            translate([0, 0, -coupling_length/3 + i * coupling_length/6])
                rotate([0, 90, 0])
                    cylinder(d=2, h=coupling_od + 1, center=true, $fn=16);
    }

    // Set screw hole for small shaft side
    translate([0, 0, -coupling_length/4])
        rotate([90, 0, 0])
            cylinder(d=set_screw_d, h=coupling_od + 1, center=true, $fn=32);

    // Set screw hole for large shaft side
    translate([0, 0, coupling_length/4])
        rotate([90, 0, 90])
            cylinder(d=set_screw_d, h=coupling_od + 1, center=true, $fn=32);

    // Flat on each bore for set screw grip
    translate([shaft_small/2 - 0.5, 0, -coupling_length/4])
        cube([1, coupling_od, coupling_length/3], center=true);
    translate([0, shaft_large/2 - 0.5, coupling_length/4])
        cube([coupling_od, 1, coupling_length/3], center=true);
}
""",
        expected_parts=["coupling_body", "small_bore", "large_bore", "set_screws", "flex_slots"],
        essential_parts=["coupling_body", "small_bore", "large_bore"],
        secondary_parts=["set_screws", "flex_slots"],
        optional_parts=["flats"]
    ),
    BenchmarkPrompt(
        id="bench_complex_04",
        text="An electronics enclosure box 80x50x25mm with lid and ventilation slots",
        category="complex",
        ground_truth_scad="""// Electronics enclosure: 80x50x25mm with lid and ventilation
box_l = 80;
box_w = 50;
box_h = 25;
wall = 2;
lid_h = 5;
vent_slots = 6;
vent_w = 3;
vent_l = 20;
boss_d = 6;
boss_hole_d = 2.5;  // M2.5 screw

// Bottom box
difference() {
    // Outer shell
    cube([box_l, box_w, box_h - lid_h], center=true);

    // Inner cavity
    translate([0, 0, wall])
        cube([box_l - wall*2, box_w - wall*2, box_h - lid_h], center=true);

    // Ventilation slots on one side
    for (i = [0:vent_slots-1]) {
        translate([i * (vent_w*2.5) - (vent_slots-1) * vent_w * 1.25, box_w/2, 0])
            cube([vent_w, wall + 1, vent_l], center=true);
    }

    // Ventilation slots on opposite side
    for (i = [0:vent_slots-1]) {
        translate([i * (vent_w*2.5) - (vent_slots-1) * vent_w * 1.25, -box_w/2, 0])
            cube([vent_w, wall + 1, vent_l], center=true);
    }
}

// Mounting bosses in corners (inside box)
for (x = [-1, 1]) {
    for (y = [-1, 1]) {
        translate([x * (box_l/2 - wall - boss_d/2), y * (box_w/2 - wall - boss_d/2), -(box_h - lid_h)/2 + wall]) {
            difference() {
                cylinder(d=boss_d, h=box_h - lid_h - wall*2, $fn=32);
                cylinder(d=boss_hole_d, h=box_h - lid_h - wall*2 + 1, $fn=32);
            }
        }
    }
}

// Lid (positioned above box)
translate([0, 0, (box_h - lid_h)/2 + lid_h/2 + 1]) {
    difference() {
        union() {
            // Lid outer
            cube([box_l, box_w, lid_h], center=true);

            // Lip that fits inside box
            translate([0, 0, -lid_h/2])
                cube([box_l - wall*2 - 0.4, box_w - wall*2 - 0.4, 2], center=true);
        }

        // Screw holes aligned with bosses
        for (x = [-1, 1]) {
            for (y = [-1, 1]) {
                translate([x * (box_l/2 - wall - boss_d/2), y * (box_w/2 - wall - boss_d/2), 0])
                    cylinder(d=boss_hole_d + 0.3, h=lid_h + 3, center=true, $fn=32);
            }
        }
    }
}
""",
        expected_parts=["box", "cavity", "lid", "vent_slots", "mounting_bosses"],
        essential_parts=["box", "cavity", "lid"],
        secondary_parts=["vent_slots", "mounting_bosses"],
        optional_parts=["lip"]
    ),
    BenchmarkPrompt(
        id="bench_complex_05",
        text="A hinge with two leaves, pin barrel, and countersunk screw holes",
        category="complex",
        ground_truth_scad="""// Hinge: two leaves with knuckles, pin, and countersunk holes
leaf_l = 40;
leaf_w = 30;
leaf_t = 2;
pin_d = 4;
barrel_od = 8;
n_knuckles = 5;
knuckle_h = leaf_l / n_knuckles;
screw_d = 3.5;
csink_d = 6.5;
csink_depth = 1.2;
n_screws = 3;

// Left leaf with knuckles at indices 0, 2, 4
difference() {
    union() {
        // Leaf plate
        translate([-leaf_w/2, 0, leaf_t/2])
            cube([leaf_w, leaf_l, leaf_t], center=true);

        // Knuckles (barrel segments)
        for (i = [0, 2, 4]) {
            translate([0, -leaf_l/2 + i * knuckle_h + knuckle_h/2, barrel_od/2])
                rotate([90, 0, 0])
                    cylinder(d=barrel_od, h=knuckle_h - 0.2, center=true, $fn=32);
        }
    }

    // Pin hole through knuckles
    translate([0, 0, barrel_od/2])
        rotate([90, 0, 0])
            cylinder(d=pin_d + 0.3, h=leaf_l + 2, center=true, $fn=32);

    // Countersunk screw holes in leaf
    for (i = [0:n_screws-1]) {
        translate([-leaf_w/2, -leaf_l/2 + (i+1) * leaf_l/(n_screws+1), 0]) {
            cylinder(d=screw_d, h=leaf_t + 1, center=true, $fn=32);
            translate([0, 0, leaf_t/2 - csink_depth])
                cylinder(d1=screw_d, d2=csink_d, h=csink_depth + 0.1, $fn=32);
        }
    }
}

// Right leaf with knuckles at indices 1, 3
translate([0, 0, 0]) {
    difference() {
        union() {
            // Leaf plate (mirrored)
            translate([leaf_w/2, 0, leaf_t/2])
                cube([leaf_w, leaf_l, leaf_t], center=true);

            // Knuckles (barrel segments)
            for (i = [1, 3]) {
                translate([0, -leaf_l/2 + i * knuckle_h + knuckle_h/2, barrel_od/2])
                    rotate([90, 0, 0])
                        cylinder(d=barrel_od, h=knuckle_h - 0.2, center=true, $fn=32);
            }
        }

        // Pin hole through knuckles
        translate([0, 0, barrel_od/2])
            rotate([90, 0, 0])
                cylinder(d=pin_d + 0.3, h=leaf_l + 2, center=true, $fn=32);

        // Countersunk screw holes in leaf
        for (i = [0:n_screws-1]) {
            translate([leaf_w/2, -leaf_l/2 + (i+1) * leaf_l/(n_screws+1), 0]) {
                cylinder(d=screw_d, h=leaf_t + 1, center=true, $fn=32);
                translate([0, 0, leaf_t/2 - csink_depth])
                    cylinder(d1=screw_d, d2=csink_d, h=csink_depth + 0.1, $fn=32);
            }
        }
    }
}

// Pin
translate([0, 0, barrel_od/2])
    rotate([90, 0, 0])
        cylinder(d=pin_d, h=leaf_l - 1, center=true, $fn=32);
""",
        expected_parts=["left_leaf", "right_leaf", "knuckles", "pin", "countersunk_holes"],
        essential_parts=["left_leaf", "right_leaf", "knuckles", "pin"],
        secondary_parts=["countersunk_holes"],
        optional_parts=[]
    ),
]


# Combine all prompts
BENCHMARK_PROMPTS = SIMPLE_PROMPTS + MEDIUM_PROMPTS + COMPLEX_PROMPTS


# =============================================================================
# BASELINE SYSTEM PROMPT (for direct GPT, no pipeline)
# =============================================================================

DIRECT_SYSTEM_PROMPT = """You are an OpenSCAD code generator. Generate valid, executable OpenSCAD code based on user descriptions.

Requirements:
1. Output ONLY valid OpenSCAD code - no explanations, no markdown
2. The code must be syntactically correct and render without errors
3. Use appropriate primitives: cube(), cylinder(), sphere()
4. Use boolean operations: union(), difference(), intersection()
5. Use transformations: translate(), rotate(), scale()
6. Include $fn=64 for smooth curves
7. Center the design at origin when appropriate

Output format: Raw OpenSCAD code only."""


# =============================================================================
# DATA STRUCTURES
# =============================================================================

@dataclass
class MethodResult:
    """Result for one method on one prompt."""
    method: str
    prompt_id: str

    # Generation
    code: Optional[str] = None
    generation_time: float = 0.0

    # Validation
    syntax_valid: bool = False
    render_success: bool = False

    # Paths
    scad_path: Optional[str] = None
    stl_path: Optional[str] = None
    image_path: Optional[str] = None

    # Chamfer (computed later)
    chamfer_distance: Optional[float] = None

    # Error
    error: Optional[str] = None


@dataclass
class BenchmarkResult:
    """Complete benchmark result for one prompt."""
    prompt: BenchmarkPrompt
    ground_truth_paths: Dict[str, str] = field(default_factory=dict)
    method_results: Dict[str, MethodResult] = field(default_factory=dict)


# =============================================================================
# OPENSCAD UTILITIES
# =============================================================================

def save_scad(code: str, path: str) -> bool:
    """Save OpenSCAD code to file."""
    try:
        Path(path).parent.mkdir(parents=True, exist_ok=True)
        with open(path, 'w') as f:
            f.write(code)
        return True
    except Exception as e:
        print(f"  Error saving SCAD: {e}")
        return False


def check_syntax(scad_path: str) -> bool:
    """Check if OpenSCAD code has valid syntax."""
    try:
        result = subprocess.run(
            ["openscad", "--export-format", "echo", "-o", "/dev/null", scad_path],
            capture_output=True, text=True, timeout=30
        )
        stderr = result.stderr.lower()
        return "error" not in stderr and "parse error" not in stderr
    except Exception:
        return False


def render_image(scad_path: str, image_path: str) -> bool:
    """Render SCAD to PNG image."""
    try:
        Path(image_path).parent.mkdir(parents=True, exist_ok=True)
        result = subprocess.run(
            ["openscad", "-o", image_path, "--imgsize=800,600",
             "--preview", "--autocenter", "--viewall", scad_path],
            capture_output=True, text=True, timeout=60
        )
        return result.returncode == 0 and Path(image_path).exists()
    except Exception:
        return False


def render_stl(scad_path: str, stl_path: str) -> bool:
    """Render SCAD to STL for Chamfer distance."""
    try:
        Path(stl_path).parent.mkdir(parents=True, exist_ok=True)
        result = subprocess.run(
            ["openscad", "-o", stl_path, scad_path],
            capture_output=True, text=True, timeout=120
        )
        return result.returncode == 0 and Path(stl_path).exists() and Path(stl_path).stat().st_size > 0
    except Exception:
        return False


# =============================================================================
# CHAMFER DISTANCE
# =============================================================================

def load_stl_as_pointcloud(stl_path: str, n_points: int = 2048) -> Optional[np.ndarray]:
    """Load STL and sample point cloud from surface."""
    try:
        import trimesh
        mesh = trimesh.load(stl_path)

        if isinstance(mesh, trimesh.Scene):
            meshes = [g for g in mesh.geometry.values() if isinstance(g, trimesh.Trimesh)]
            if not meshes:
                return None
            mesh = trimesh.util.concatenate(meshes)

        if not isinstance(mesh, trimesh.Trimesh):
            return None

        points, _ = trimesh.sample.sample_surface(mesh, n_points)
        return points
    except Exception as e:
        print(f"  Warning: Failed to load STL: {e}")
        return None


def compute_chamfer_distance(pc1: np.ndarray, pc2: np.ndarray) -> float:
    """Compute Chamfer distance between two point clouds."""
    from scipy.spatial.distance import cdist

    dist_matrix = cdist(pc1, pc2)
    min_dist_1_to_2 = np.min(dist_matrix, axis=1)
    min_dist_2_to_1 = np.min(dist_matrix, axis=0)

    return float(np.mean(min_dist_1_to_2) + np.mean(min_dist_2_to_1))


# =============================================================================
# METHOD RUNNERS
# =============================================================================

class DirectBaseline:
    """Direct GPT baseline - NO pipeline, NO VLM, NO verification."""

    def __init__(self, client: OpenAI, model: str = "gpt-4o"):
        self.client = client
        self.model = model

    def generate(self, prompt_text: str) -> Tuple[str, float, dict]:
        """Generate OpenSCAD code directly (no pipeline features)."""
        start = time.time()
        extra_info = {}

        try:
            kwargs = {
                "model": self.model,
                "messages": [
                    {"role": "system", "content": DIRECT_SYSTEM_PROMPT},
                    {"role": "user", "content": f"Generate OpenSCAD code for: {prompt_text}"}
                ],
                "temperature": 0.2,
            }

            if self.model in ["gpt-5.1", "gpt-5.2"]:
                kwargs["max_completion_tokens"] = 2000
            else:
                kwargs["max_tokens"] = 2000

            response = self.client.chat.completions.create(**kwargs)
            code = response.choices[0].message.content.strip()

            # Clean markdown if present
            if "```" in code:
                import re
                match = re.search(r"```(?:openscad|scad)?\s*\n?(.*?)```", code, re.DOTALL)
                if match:
                    code = match.group(1).strip()

            return code, time.time() - start, extra_info

        except Exception as e:
            print(f"  Error in direct generation: {e}")
            return "", time.time() - start, extra_info


class CADencePipeline:
    """Basic CADence pipeline: reasoner -> planner -> compiler -> save/render.

    No VLM self-correction, no component verification.
    This is the V1 basic pipeline for establishing baseline performance.
    """

    def __init__(
        self,
        client: OpenAI,
        pipeline_model: str = "gpt-4o",
        reasoning_model: str = "gpt-5.2",
        use_rag: bool = False,
    ):
        self.openai_client = client
        self.pipeline_model = pipeline_model
        self.reasoning_model = reasoning_model
        self.use_rag = use_rag

        self._initialized = False

    def _init(self):
        """Lazily initialize pipeline components."""
        if self._initialized:
            return

        from core import TextReasoner, Planner, Compiler, Validator
        from core.llm_client import create_unified_client

        self.unified_client = create_unified_client(openai_client=self.openai_client)

        # Use reasoning model for understanding/planning, pipeline model for compilation
        self.reasoner = TextReasoner(self.unified_client, self.reasoning_model)
        self.planner = Planner(self.unified_client, self.reasoning_model)
        self.compiler = Compiler(self.unified_client, self.pipeline_model)
        self.validator = Validator(pass_threshold=0.80)

        # RAG retriever (optional)
        if self.use_rag:
            try:
                from kb.retriever import KnowledgeRetriever
                self.retriever = KnowledgeRetriever()
                print("  [RAG] Knowledge base loaded")
            except Exception as e:
                print(f"  [RAG] Warning: KB not available: {e}")
                self.retriever = None
        else:
            self.retriever = None

        self._initialized = True

    def generate(
        self,
        prompt_text: str,
        prompt: BenchmarkPrompt,
        scad_path: str,
        image_path: str
    ) -> Tuple[str, float, dict]:
        """Generate OpenSCAD via basic CADence pipeline (no VLM, no verification)."""
        self._init()

        start = time.time()
        extra_info = {}

        try:
            # Stage 1: Understanding
            design_brief = self.reasoner.analyze(prompt_text)

            # Stage 1.5: RAG augmentation (if enabled)
            if self.use_rag and self.retriever:
                try:
                    context = self.retriever.retrieve(prompt_text)
                    if context and context.results:
                        design_brief.kb_context = context.get_context_prompt()
                        print(f"  [RAG] Retrieved {len(context.results)} components")
                except Exception as e:
                    print(f"  [RAG] Retrieval failed: {e}")

            # Stage 2: Planning
            plan_result = self.planner.create_plan(design_brief, max_attempts=2)
            if not plan_result.valid:
                return "", time.time() - start, extra_info

            # Stage 3: Compilation
            code = self.compiler.compile(plan_result.plan)

            # Stage 4: Save and render
            save_scad(code, scad_path)
            render_image(scad_path, image_path)

            return code, time.time() - start, extra_info

        except Exception as e:
            print(f"  Error in CADence pipeline: {e}")
            import traceback
            traceback.print_exc()
            return "", time.time() - start, extra_info


# =============================================================================
# MAIN BENCHMARK RUNNER
# =============================================================================

class NopSCADlibBenchmark:
    """Main benchmark runner."""

    def __init__(self, output_dir: str = None, methods: List[str] = None):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        self.output_dir = Path(output_dir or f"./evaluation/nopscadlib_benchmark_v1/{timestamp}")
        self.output_dir.mkdir(parents=True, exist_ok=True)

        # Create subdirectories
        for subdir in ["ground_truth", "gpt4o", "gpt52", "cadence", "cadence_rag",
                       "stl", "images"]:
            (self.output_dir / subdir).mkdir(exist_ok=True)

        # Methods to run
        self.methods = methods or ["gpt4o", "gpt52", "cadence", "cadence_rag"]

        # Initialize OpenAI client
        self.client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

        # Initialize method runners
        self.runners = {}

        if "gpt4o" in self.methods:
            self.runners["gpt4o"] = DirectBaseline(self.client, "gpt-4o")
        if "gpt52" in self.methods:
            self.runners["gpt52"] = DirectBaseline(self.client, "gpt-5.2")
        if "cadence" in self.methods:
            self.runners["cadence"] = CADencePipeline(
                self.client,
                pipeline_model="gpt-4o",
                reasoning_model="gpt-5.2",
                use_rag=False,
            )
        if "cadence_rag" in self.methods:
            self.runners["cadence_rag"] = CADencePipeline(
                self.client,
                pipeline_model="gpt-4o",
                reasoning_model="gpt-5.2",
                use_rag=True,
            )

        print(f"[Benchmark V1] Output: {self.output_dir}")
        print(f"[Benchmark V1] Methods: {self.methods}")
        print(f"[Benchmark V1] Pipeline: basic (no VLM correction, no verification)")

    def run(self, prompts: List[BenchmarkPrompt] = None) -> Dict[str, Any]:
        """Run the complete benchmark."""
        prompts = prompts or BENCHMARK_PROMPTS

        print(f"\n{'='*70}")
        print("NopSCADlib Ground Truth Benchmark V1")
        print("Generic prompts, basic pipeline (no VLM/verification)")
        print(f"{'='*70}")
        print(f"Prompts: {len(prompts)}")
        print(f"Methods: {', '.join(self.methods)}")
        print(f"CADence: Basic pipeline only (reasoner+planner+compiler)")
        print(f"Baselines: Direct generation only (no pipeline)")
        print(f"{'='*70}\n")

        results = []

        for i, prompt in enumerate(prompts):
            print(f"\n[{i+1}/{len(prompts)}] {prompt.id}: {prompt.text[:60]}...")

            bench_result = BenchmarkResult(prompt=prompt)

            # Generate ground truth STL
            gt_scad_path = self.output_dir / "ground_truth" / f"{prompt.id}.scad"
            gt_stl_path = self.output_dir / "stl" / f"{prompt.id}_gt.stl"

            save_scad(prompt.ground_truth_scad, str(gt_scad_path))
            render_stl(str(gt_scad_path), str(gt_stl_path))

            bench_result.ground_truth_paths = {
                "scad": str(gt_scad_path),
                "stl": str(gt_stl_path)
            }

            # Run each method
            for method_name, runner in self.runners.items():
                print(f"  [{method_name}] Generating...")

                method_result = MethodResult(method=method_name, prompt_id=prompt.id)

                scad_path = self.output_dir / method_name / f"{prompt.id}.scad"
                stl_path = self.output_dir / "stl" / f"{prompt.id}_{method_name}.stl"
                image_path = self.output_dir / "images" / f"{prompt.id}_{method_name}.png"

                # Generate code
                if isinstance(runner, DirectBaseline):
                    code, gen_time, extra = runner.generate(prompt.text)
                else:
                    code, gen_time, extra = runner.generate(
                        prompt.text, prompt, str(scad_path), str(image_path)
                    )

                method_result.code = code
                method_result.generation_time = gen_time

                if code:
                    # For direct baselines, save and render here
                    if isinstance(runner, DirectBaseline):
                        save_scad(code, str(scad_path))
                        render_image(str(scad_path), str(image_path))

                    method_result.scad_path = str(scad_path)
                    method_result.syntax_valid = check_syntax(str(scad_path))

                    if method_result.syntax_valid:
                        method_result.render_success = render_stl(str(scad_path), str(stl_path))
                        if method_result.render_success:
                            method_result.stl_path = str(stl_path)

                        if Path(image_path).exists():
                            method_result.image_path = str(image_path)

                    # Compute Chamfer distance
                    if method_result.stl_path and gt_stl_path.exists():
                        print(f"  [{method_name}] Computing Chamfer distance...")
                        gt_pc = load_stl_as_pointcloud(str(gt_stl_path))
                        method_pc = load_stl_as_pointcloud(str(method_result.stl_path))

                        if gt_pc is not None and method_pc is not None:
                            method_result.chamfer_distance = compute_chamfer_distance(gt_pc, method_pc)
                            print(f"  [{method_name}] Chamfer: {method_result.chamfer_distance:.4f}")

                bench_result.method_results[method_name] = method_result

            results.append(bench_result)

            # Save intermediate results
            self._save_results(results)
            time.sleep(0.5)

        # Compute and save summary
        summary = self._compute_summary(results)
        self._save_summary(summary)
        self._print_summary(summary)

        return summary

    def _compute_summary(self, results: List[BenchmarkResult]) -> Dict[str, Any]:
        """Compute summary statistics."""
        summary = {
            "n_prompts": len(results),
            "methods": self.methods,
            "version": "v1_basic_pipeline",
            "by_method": {},
            "by_category": {},
            "detailed_results": []
        }

        # Per-method stats
        for method in self.methods:
            method_results = [r.method_results.get(method) for r in results if method in r.method_results]
            valid_results = [r for r in method_results if r]

            chamfer_values = [r.chamfer_distance for r in valid_results if r.chamfer_distance is not None]

            summary["by_method"][method] = {
                "syntax_rate": sum(r.syntax_valid for r in valid_results) / len(valid_results) * 100 if valid_results else 0,
                "render_rate": sum(r.render_success for r in valid_results) / len(valid_results) * 100 if valid_results else 0,
                "avg_chamfer": float(np.mean(chamfer_values)) if chamfer_values else None,
                "std_chamfer": float(np.std(chamfer_values)) if chamfer_values else None,
                "median_chamfer": float(np.median(chamfer_values)) if chamfer_values else None,
                "n_valid_chamfer": len(chamfer_values),
                "avg_time": float(np.mean([r.generation_time for r in valid_results])) if valid_results else 0,
            }

        # Per-category stats
        for category in ["simple", "medium", "complex"]:
            cat_results = [r for r in results if r.prompt.category == category]
            summary["by_category"][category] = {"n_prompts": len(cat_results)}

            for method in self.methods:
                method_cat_results = [r.method_results.get(method) for r in cat_results if method in r.method_results]
                chamfer_values = [r.chamfer_distance for r in method_cat_results if r and r.chamfer_distance is not None]

                summary["by_category"][category][method] = {
                    "avg_chamfer": float(np.mean(chamfer_values)) if chamfer_values else None,
                    "median_chamfer": float(np.median(chamfer_values)) if chamfer_values else None,
                    "render_rate": sum(r.render_success for r in method_cat_results if r) / len(method_cat_results) * 100 if method_cat_results else 0
                }

        # Detailed per-prompt results
        for r in results:
            prompt_detail = {
                "id": r.prompt.id,
                "text": r.prompt.text,
                "category": r.prompt.category,
                "chamfer_distances": {}
            }
            for method, mr in r.method_results.items():
                prompt_detail["chamfer_distances"][method] = mr.chamfer_distance
            summary["detailed_results"].append(prompt_detail)

        return summary

    def _save_results(self, results: List[BenchmarkResult]):
        """Save detailed results to JSON."""
        output = []
        for r in results:
            output.append({
                "prompt_id": r.prompt.id,
                "prompt_text": r.prompt.text,
                "category": r.prompt.category,
                "ground_truth_paths": r.ground_truth_paths,
                "method_results": {
                    method: asdict(mr) for method, mr in r.method_results.items()
                }
            })

        with open(self.output_dir / "detailed_results.json", "w") as f:
            json.dump(output, f, indent=2, default=str)

    def _save_summary(self, summary: Dict[str, Any]):
        """Save summary to JSON."""
        with open(self.output_dir / "benchmark_summary.json", "w") as f:
            json.dump(summary, f, indent=2, default=str)

        # Generate LaTeX table
        self._generate_latex_table(summary)

    def _generate_latex_table(self, summary: Dict[str, Any]):
        """Generate LaTeX table for paper."""
        lines = []
        lines.append("% Auto-generated from NopSCADlib benchmark V1 (basic pipeline)")
        lines.append("\\begin{table}[t]")
        lines.append("\\centering")
        lines.append("\\caption{V1 Benchmark: Chamfer Distance (CD) to ground truth. Lower CD = better geometric fidelity. CADence methods use basic pipeline (no VLM/verification); baselines use direct generation only.}")
        lines.append("\\label{tab:nopscadlib-benchmark-v1}")
        lines.append("\\setlength{\\tabcolsep}{3pt}")
        lines.append("\\begin{tabular}{llccc}")
        lines.append("\\toprule")
        lines.append("\\textbf{Complexity} & \\textbf{Method} & \\textbf{Render\\%} & \\textbf{CD Mean}$\\downarrow$ & \\textbf{CD Med.}$\\downarrow$ \\\\")
        lines.append("\\midrule")

        method_labels = {
            "gpt4o": "GPT-4o (direct)",
            "gpt52": "GPT-5.2 (direct)",
            "cadence": "CADence (basic)",
            "cadence_rag": "CADence + RAG (basic)"
        }

        for category in ["simple", "medium", "complex"]:
            cat_data = summary["by_category"].get(category, {})
            n = cat_data.get("n_prompts", 0)

            lines.append(f"\\multirow{{{len(self.methods)}}}{{*}}{{{category.capitalize()} ({n})}}")

            for i, method in enumerate(self.methods):
                method_data = cat_data.get(method, {})
                label = method_labels.get(method, method)
                render_rate = method_data.get("render_rate", 0)
                avg_cd = method_data.get("avg_chamfer")
                med_cd = method_data.get("median_chamfer")

                avg_str = f"{avg_cd:.2f}" if avg_cd is not None else "N/A"
                med_str = f"{med_cd:.2f}" if med_cd is not None else "N/A"

                prefix = "  & " if i > 0 else "  "
                lines.append(f"{prefix}{label} & {render_rate:.0f}\\% & {avg_str} & {med_str} \\\\")

            if category != "complex":
                lines.append("\\midrule")

        lines.append("\\bottomrule")
        lines.append("\\end{tabular}")
        lines.append("\\end{table}")

        with open(self.output_dir / "latex_table.tex", "w") as f:
            f.write("\n".join(lines))

        print(f"\nLaTeX table saved to: {self.output_dir / 'latex_table.tex'}")

    def _print_summary(self, summary: Dict[str, Any]):
        """Print summary to console."""
        print(f"\n{'='*70}")
        print("BENCHMARK V1 SUMMARY (Basic Pipeline)")
        print(f"{'='*70}")

        print(f"\nTotal prompts: {summary['n_prompts']}")

        print("\n--- Per-Method Results ---")
        for method in self.methods:
            data = summary["by_method"].get(method, {})
            print(f"\n{method}:")
            print(f"  Syntax Pass:    {data.get('syntax_rate', 0):.1f}%")
            print(f"  Render Success: {data.get('render_rate', 0):.1f}%")
            avg_cd = data.get('avg_chamfer')
            if avg_cd is not None:
                print(f"  Avg Chamfer:    {avg_cd:.4f} (n={data.get('n_valid_chamfer', 0)})")
            else:
                print(f"  Avg Chamfer:    N/A")
            print(f"  Avg Time:       {data.get('avg_time', 0):.2f}s")

        print("\n--- Per-Category Chamfer Distance ---")
        print(f"{'Category':<10} | " + " | ".join(f"{m:<12}" for m in self.methods))
        print("-" * (12 + 15 * len(self.methods)))

        for category in ["simple", "medium", "complex"]:
            cat_data = summary["by_category"].get(category, {})
            values = []
            for method in self.methods:
                method_data = cat_data.get(method, {})
                avg_cd = method_data.get("avg_chamfer")
                values.append(f"{avg_cd:.2f}" if avg_cd is not None else "N/A")
            print(f"{category:<10} | " + " | ".join(f"{v:<12}" for v in values))

        print(f"\n{'='*70}")


# =============================================================================
# CLI
# =============================================================================

def main():
    parser = argparse.ArgumentParser(
        description="NopSCADlib Ground Truth Benchmark V1 (Generic prompts, basic pipeline)",
        formatter_class=argparse.RawDescriptionHelpFormatter
    )

    parser.add_argument("--quick", action="store_true",
                        help="Quick test with only 3 prompts")
    parser.add_argument("--methods", nargs="+",
                        choices=["gpt4o", "gpt52", "cadence", "cadence_rag"],
                        help="Methods to run (default: all)")
    parser.add_argument("--output-dir", type=str,
                        help="Output directory (auto-generated if not specified)")
    parser.add_argument("--category", type=str,
                        choices=["simple", "medium", "complex"],
                        help="Run only prompts from this category")

    args = parser.parse_args()

    # Select prompts
    prompts = BENCHMARK_PROMPTS

    if args.category:
        prompts = [p for p in prompts if p.category == args.category]

    if args.quick:
        # One from each category
        prompts = [
            next(p for p in BENCHMARK_PROMPTS if p.category == "simple"),
            next(p for p in BENCHMARK_PROMPTS if p.category == "medium"),
            next(p for p in BENCHMARK_PROMPTS if p.category == "complex"),
        ]

    # Run benchmark
    benchmark = NopSCADlibBenchmark(
        output_dir=args.output_dir,
        methods=args.methods
    )

    benchmark.run(prompts)


if __name__ == "__main__":
    main()
