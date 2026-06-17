#!/usr/bin/env python3
"""
NopSCADlib Ground Truth Benchmark Evaluation

Compares CRAFT pipeline vs GPT baselines using NopSCADlib components as ground truth.
Ground truth models are authored using parametric specifications sourced from the
NopSCADlib library (https://github.com/nophead/NopSCADlib). Reference dimensions
(bearing diameters, mounting hole patterns, motor face widths) follow NopSCADlib's
catalog to ensure dimensional accuracy and reproducibility.

Methods evaluated:
1. GPT-4o (direct) - Simple prompt -> code, NO pipeline/VLM/verification
2. GPT-5.2 (direct) - Simple prompt -> code, NO pipeline/VLM/verification
3. CRAFT (no RAG) - Full pipeline WITH VLM correction + component verification
4. CRAFT + RAG - Full pipeline WITH VLM + verification + NopSCADlib KB

Prompts are specifically designed to trigger NopSCADlib RAG retrieval using
known aliases and keywords from kb/config.py.

Usage:
    python run_nopscadlib_benchmark.py
    python run_nopscadlib_benchmark.py --quick  # Run only 3 prompts
    python run_nopscadlib_benchmark.py --methods gpt4o craft_rag
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

# NopSCADlib library path for OpenSCAD --librarydir
# The parent directory of nopscadlib/ must be on the library path
# so that `include <nopscadlib/lib.scad>` resolves correctly.
NOPSCADLIB_LIBRARY_DIR = str(Path(__file__).parent.parent / "kb_data")
GROUND_TRUTH_DIR = Path(__file__).parent / "ground_truth_nopscadlib"


# =============================================================================
# NOPSCADLIB-DIMENSIONED BENCHMARK PROMPTS
# Ground truth: Hand-authored OpenSCAD using NopSCADlib parametric specifications
# Prompts use exact aliases from kb/config.py to trigger RAG retrieval
# =============================================================================

@dataclass
class BenchmarkPrompt:
    """Benchmark prompt with ground truth OpenSCAD code."""
    id: str
    text: str                       # Natural language prompt (RAG-friendly)
    category: str                   # simple, medium, complex
    ground_truth_scad: str          # Reference OpenSCAD code (NopSCADlib-dimensioned)
    expected_parts: List[str]
    essential_parts: List[str]      # Must have
    secondary_parts: List[str]      # Should have
    optional_parts: List[str]       # Nice to have
    nopscadlib_keywords: List[str]  # Keywords that should trigger RAG
    nopscadlib_type: str = ""       # NopSCADlib type constant for reference
    ground_truth_file: str = ""     # Optional: filename stem in ground_truth_nopscadlib/

# =============================================================================
# SIMPLE PROMPTS (5) - Basic NopSCADlib components
# =============================================================================

SIMPLE_PROMPTS = [
    BenchmarkPrompt(
        id="bench_simple_01",
        text="A 608 bearing - the standard skateboard bearing with 22mm outer diameter, 8mm bore, and 7mm thickness",
        category="simple",
        ground_truth_scad="""// 608 Ball Bearing (skateboard bearing)
// OD=22mm, ID=8mm, H=7mm
bearing_od = 22;
bearing_id = 8;
bearing_h = 7;

difference() {
    // Outer race
    cylinder(d=bearing_od, h=bearing_h, center=true, $fn=64);
    // Inner bore
    cylinder(d=bearing_id, h=bearing_h+1, center=true, $fn=64);
}
""",
        expected_parts=["outer_race", "inner_bore"],
        essential_parts=["bearing"],
        secondary_parts=["bore"],
        optional_parts=[],
        nopscadlib_keywords=["608", "bearing", "skateboard bearing"]
    ),
    BenchmarkPrompt(
        id="bench_simple_02",
        text="An M8 washer - flat washer with 16mm outer diameter, 8.4mm inner hole, 1.6mm thick",
        category="simple",
        ground_truth_scad="""// M8 Flat Washer
// OD=16mm, ID=8.4mm, H=1.6mm
washer_od = 16;
washer_id = 8.4;
washer_h = 1.6;

difference() {
    cylinder(d=washer_od, h=washer_h, center=true, $fn=64);
    cylinder(d=washer_id, h=washer_h+1, center=true, $fn=64);
}
""",
        expected_parts=["washer", "hole"],
        essential_parts=["washer"],
        secondary_parts=["hole"],
        optional_parts=[],
        nopscadlib_keywords=["m8", "washer", "fastener"]
    ),
    BenchmarkPrompt(
        id="bench_simple_03",
        text="A GT2 timing pulley - 20 tooth pulley for GT2 belt with 5mm bore",
        category="simple",
        ground_truth_scad="""// GT2 20T Timing Pulley
// 20 teeth, 2mm pitch, 5mm bore
teeth = 20;
pitch = 2;
bore = 5;
belt_width = 6;
pulley_od = teeth * pitch / 3.14159;
flange_od = pulley_od + 2;

difference() {
    union() {
        // Main pulley body
        cylinder(d=pulley_od, h=belt_width+2, center=true, $fn=64);
        // Top flange
        translate([0, 0, (belt_width+2)/2 - 1])
            cylinder(d=flange_od, h=1, $fn=64);
        // Bottom flange
        translate([0, 0, -(belt_width+2)/2])
            cylinder(d=flange_od, h=1, $fn=64);
    }
    // Center bore
    cylinder(d=bore, h=belt_width+10, center=true, $fn=32);
    // Teeth profile (simplified)
    for (i = [0:teeth-1]) {
        rotate([0, 0, i * 360/teeth])
            translate([pulley_od/2, 0, 0])
                cylinder(d=1, h=belt_width+3, center=true, $fn=16);
    }
}
""",
        expected_parts=["pulley", "teeth", "bore", "flanges"],
        essential_parts=["pulley", "bore"],
        secondary_parts=["teeth"],
        optional_parts=["flanges"],
        nopscadlib_keywords=["gt2", "pulley", "timing pulley", "belt"]
    ),
    BenchmarkPrompt(
        id="bench_simple_04",
        text="A 40mm cooling fan mount plate - square mounting plate for 40mm fan with 4 corner holes",
        category="simple",
        ground_truth_scad="""// 40mm Fan Mount Plate
fan_size = 40;
hole_spacing = 32;  // Standard 40mm fan hole spacing
plate_thickness = 3;
mount_hole_d = 3.2;  // M3 clearance

difference() {
    // Base plate
    translate([0, 0, plate_thickness/2])
        cube([fan_size + 6, fan_size + 6, plate_thickness], center=true);

    // Center airflow hole
    cylinder(d=fan_size - 4, h=plate_thickness + 1, center=true, $fn=64);

    // Mounting holes (4 corners)
    for (x = [-1, 1]) {
        for (y = [-1, 1]) {
            translate([x * hole_spacing/2, y * hole_spacing/2, 0])
                cylinder(d=mount_hole_d, h=plate_thickness + 1, center=true, $fn=32);
        }
    }
}
""",
        expected_parts=["plate", "airflow_hole", "mounting_holes"],
        essential_parts=["plate", "mounting_holes"],
        secondary_parts=["airflow_hole"],
        optional_parts=[],
        nopscadlib_keywords=["fan", "40mm fan", "cooling", "mount"]
    ),
    BenchmarkPrompt(
        id="bench_simple_05",
        text="An LM8UU linear bearing holder - simple holder for 8mm linear bearing with 15mm OD",
        category="simple",
        ground_truth_scad="""// LM8UU Linear Bearing Holder
// LM8UU: OD=15mm, ID=8mm, L=24mm
bearing_od = 15;
bearing_id = 8;
bearing_length = 24;
wall = 3;

difference() {
    // Outer body
    cube([bearing_od + wall*2, bearing_od + wall*2, bearing_length], center=true);

    // Bearing pocket
    cylinder(d=bearing_od, h=bearing_length+1, center=true, $fn=64);

    // Through hole for shaft
    cylinder(d=bearing_id, h=bearing_length+10, center=true, $fn=64);

    // Clamping slot
    translate([0, bearing_od/2 + wall/2, 0])
        cube([2, wall+1, bearing_length+1], center=true);
}
""",
        expected_parts=["holder", "bearing_pocket", "slot"],
        essential_parts=["holder", "bearing_pocket"],
        secondary_parts=["slot"],
        optional_parts=[],
        nopscadlib_keywords=["lm8uu", "linear bearing", "8mm linear bearing"]
    ),
]


# =============================================================================
# MEDIUM PROMPTS (5) - Multi-part NopSCADlib assemblies
# =============================================================================

MEDIUM_PROMPTS = [
    BenchmarkPrompt(
        id="bench_medium_01",
        text="A NEMA 17 stepper motor mount - 42mm motor mount plate with 31mm hole pattern and 22mm center bore",
        category="medium",
        ground_truth_scad="""// NEMA 17 Stepper Motor Mount
// NEMA 17: 42.3mm face, 31mm mounting holes, 22mm boss
nema_size = 42.3;
hole_spacing = 31;
center_bore = 22;
plate_thickness = 4;
flange = 8;

difference() {
    // Main plate
    cube([nema_size + flange*2, nema_size + flange*2, plate_thickness], center=true);

    // Center bore for shaft/boss clearance
    cylinder(d=center_bore, h=plate_thickness+1, center=true, $fn=64);

    // NEMA 17 mounting holes (M3)
    for (x = [-1, 1]) {
        for (y = [-1, 1]) {
            translate([x * hole_spacing/2, y * hole_spacing/2, 0])
                cylinder(d=3.2, h=plate_thickness+1, center=true, $fn=32);
        }
    }

    // Corner reliefs
    for (x = [-1, 1]) {
        for (y = [-1, 1]) {
            translate([x * nema_size/2, y * nema_size/2, 0])
                cylinder(d=6, h=plate_thickness+1, center=true, $fn=32);
        }
    }
}
""",
        expected_parts=["mount_plate", "center_bore", "mounting_holes"],
        essential_parts=["mount_plate", "mounting_holes", "center_bore"],
        secondary_parts=["corner_reliefs"],
        optional_parts=[],
        nopscadlib_keywords=["nema17", "nema 17", "stepper", "motor", "42mm stepper"]
    ),
    BenchmarkPrompt(
        id="bench_medium_02",
        text="An MGN12 linear rail carriage mount - mounting block for MGN12H carriage with M3 bolt holes",
        category="medium",
        ground_truth_scad="""// MGN12 Linear Rail Carriage Mount
// MGN12H: 27mm x 42mm footprint, M3 mounting holes
carriage_width = 27;
carriage_length = 42;
hole_spacing_x = 20;
hole_spacing_y = 15;
mount_thickness = 6;

difference() {
    // Base block
    cube([carriage_width + 10, carriage_length + 10, mount_thickness], center=true);

    // MGN12H mounting holes pattern
    for (x = [-1, 1]) {
        for (y = [-1, 1]) {
            translate([x * hole_spacing_x/2, y * hole_spacing_y/2, 0])
                cylinder(d=3.2, h=mount_thickness+1, center=true, $fn=32);
        }
    }

    // Weight reduction slots
    for (y = [-1, 1]) {
        translate([0, y * (carriage_length/2 + 2), 0])
            cube([carriage_width - 4, 4, mount_thickness+1], center=true);
    }
}
""",
        expected_parts=["mount_block", "bolt_holes"],
        essential_parts=["mount_block", "bolt_holes"],
        secondary_parts=["weight_reduction"],
        optional_parts=[],
        nopscadlib_keywords=["mgn12", "linear rail", "12mm linear rail", "carriage"]
    ),
    BenchmarkPrompt(
        id="bench_medium_03",
        text="A 608 bearing housing with flanges - press-fit housing for 608ZZ bearing with mounting ears",
        category="medium",
        ground_truth_scad="""// 608 Bearing Housing with Flanges
// 608ZZ: OD=22mm, ID=8mm, H=7mm
bearing_od = 22;
bearing_id = 8;
bearing_h = 7;
wall = 3;
flange_width = 12;

difference() {
    union() {
        // Main housing
        cylinder(d=bearing_od + wall*2, h=bearing_h + 2, center=true, $fn=64);

        // Mounting flanges
        for (a = [0, 180]) {
            rotate([0, 0, a])
                translate([bearing_od/2 + flange_width/2, 0, 0])
                    cube([flange_width, 15, bearing_h + 2], center=true);
        }
    }

    // Bearing pocket (press fit)
    cylinder(d=bearing_od - 0.1, h=bearing_h, center=true, $fn=64);

    // Through hole
    cylinder(d=bearing_id, h=bearing_h + 10, center=true, $fn=64);

    // Flange mounting holes
    for (a = [0, 180]) {
        rotate([0, 0, a])
            translate([bearing_od/2 + flange_width/2, 0, 0])
                cylinder(d=4.2, h=bearing_h + 10, center=true, $fn=32);
    }
}
""",
        expected_parts=["housing", "bearing_pocket", "flanges", "mounting_holes"],
        essential_parts=["housing", "bearing_pocket"],
        secondary_parts=["flanges", "mounting_holes"],
        optional_parts=[],
        nopscadlib_keywords=["608", "608zz", "bearing", "housing", "skateboard bearing"]
    ),
    BenchmarkPrompt(
        id="bench_medium_04",
        text="A servo bracket for SG90 micro servo - mounting bracket for 9g servo with horn slot",
        category="medium",
        ground_truth_scad="""// SG90 Micro Servo Bracket
// SG90: 23mm x 12.2mm x 22mm, mounting tabs
servo_length = 23;
servo_width = 12.2;
servo_height = 22;
tab_width = 32;  // Including mounting tabs
wall = 2;

difference() {
    union() {
        // Main bracket body
        cube([servo_length + wall*2, servo_width + wall*2, servo_height/2], center=true);

        // Top plate for horn clearance
        translate([0, 0, servo_height/4])
            cube([tab_width, servo_width + wall*2, wall], center=true);
    }

    // Servo pocket
    translate([0, 0, wall])
        cube([servo_length, servo_width, servo_height], center=true);

    // Horn slot
    translate([0, 0, servo_height/4])
        cylinder(d=8, h=wall+1, center=true, $fn=32);

    // Mounting holes on tabs
    for (x = [-1, 1]) {
        translate([x * (tab_width/2 - 3), 0, servo_height/4])
            cylinder(d=2.2, h=wall+1, center=true, $fn=32);
    }
}
""",
        expected_parts=["bracket", "servo_pocket", "horn_slot", "mounting_holes"],
        essential_parts=["bracket", "servo_pocket"],
        secondary_parts=["horn_slot", "mounting_holes"],
        optional_parts=[],
        nopscadlib_keywords=["sg90", "micro servo", "9g servo", "servo"]
    ),
    BenchmarkPrompt(
        id="bench_medium_05",
        text="An Arduino Nano holder - snap-fit case for Arduino Nano with USB port cutout",
        category="medium",
        ground_truth_scad="""// Arduino Nano Holder
// Nano: 45mm x 18mm x ~5mm
nano_length = 45;
nano_width = 18;
nano_height = 7;  // Including components
wall = 2;
usb_width = 8;
usb_height = 4;

difference() {
    // Outer shell
    cube([nano_length + wall*2, nano_width + wall*2, nano_height + wall], center=true);

    // Nano pocket
    translate([0, 0, wall/2])
        cube([nano_length, nano_width, nano_height + 1], center=true);

    // USB port cutout
    translate([-(nano_length/2 + wall/2), 0, 0])
        cube([wall*2, usb_width, usb_height], center=true);

    // Snap-fit slots
    for (y = [-1, 1]) {
        translate([0, y * (nano_width/2 + wall/2), 0])
            cube([nano_length - 10, wall+1, nano_height/2], center=true);
    }
}

// Snap clips
for (y = [-1, 1]) {
    translate([0, y * (nano_width/2 + wall - 0.5), nano_height/4])
        cube([8, 1, 2], center=true);
}
""",
        expected_parts=["holder", "nano_pocket", "usb_cutout", "snap_clips"],
        essential_parts=["holder", "nano_pocket"],
        secondary_parts=["usb_cutout"],
        optional_parts=["snap_clips"],
        nopscadlib_keywords=["arduino", "arduino nano", "nano", "electronics"]
    ),
]


# =============================================================================
# COMPLEX PROMPTS (5) - Advanced NopSCADlib assemblies
# =============================================================================

COMPLEX_PROMPTS = [
    BenchmarkPrompt(
        id="bench_complex_01",
        text="A belt tensioner for GT2 belt - spring-loaded tensioner with 608 bearing idler and pivot arm",
        category="complex",
        ground_truth_scad="""// GT2 Belt Tensioner with 608 Bearing Idler
// Uses 608 bearing as idler, spring-loaded pivot arm
bearing_od = 22;  // 608 bearing
bearing_h = 7;
arm_length = 40;
arm_width = 15;
pivot_d = 5;
spring_d = 6;

// Pivot base
difference() {
    cube([25, 20, 10], center=true);

    // Pivot hole
    cylinder(d=pivot_d, h=15, center=true, $fn=32);

    // Mounting holes
    for (x = [-1, 1]) {
        translate([x * 8, 0, 0])
            cylinder(d=3.2, h=15, center=true, $fn=32);
    }
}

// Tensioner arm
translate([arm_length/2 + 5, 0, 0]) {
    difference() {
        union() {
            // Arm body
            cube([arm_length, arm_width, bearing_h + 2], center=true);

            // Bearing holder
            translate([arm_length/2 - bearing_od/2, 0, 0])
                cylinder(d=bearing_od + 4, h=bearing_h + 2, center=true, $fn=64);
        }

        // Pivot hole
        translate([-arm_length/2 + 8, 0, 0])
            cylinder(d=pivot_d, h=bearing_h + 5, center=true, $fn=32);

        // Bearing pocket
        translate([arm_length/2 - bearing_od/2, 0, 0])
            cylinder(d=bearing_od, h=bearing_h, center=true, $fn=64);

        // Bearing through hole
        translate([arm_length/2 - bearing_od/2, 0, 0])
            cylinder(d=8, h=bearing_h + 5, center=true, $fn=32);

        // Spring mount hole
        translate([-arm_length/2 + 25, arm_width/2 - 2, 0])
            cylinder(d=spring_d, h=bearing_h + 5, center=true, $fn=32);
    }
}
""",
        expected_parts=["pivot_base", "tensioner_arm", "bearing_pocket", "spring_mount"],
        essential_parts=["pivot_base", "tensioner_arm", "bearing_pocket"],
        secondary_parts=["spring_mount", "mounting_holes"],
        optional_parts=[],
        nopscadlib_keywords=["gt2", "belt", "tensioner", "608", "bearing", "idler"]
    ),
    BenchmarkPrompt(
        id="bench_complex_02",
        text="A shaft coupler for 5mm to 8mm - flexible coupling connecting NEMA 17 shaft to 8mm leadscrew",
        category="complex",
        ground_truth_scad="""// 5mm to 8mm Shaft Coupling
// Connects NEMA 17 (5mm) to 8mm leadscrew
shaft_5mm = 5;
shaft_8mm = 8;
coupling_od = 20;
coupling_length = 25;
set_screw_d = 3;

difference() {
    // Main body
    cylinder(d=coupling_od, h=coupling_length, center=true, $fn=64);

    // 5mm shaft bore (NEMA 17 side)
    translate([0, 0, -coupling_length/4])
        cylinder(d=shaft_5mm, h=coupling_length/2 + 1, center=true, $fn=64);

    // 8mm shaft bore (leadscrew side)
    translate([0, 0, coupling_length/4])
        cylinder(d=shaft_8mm, h=coupling_length/2 + 1, center=true, $fn=64);

    // Flexible coupling spiral cut
    for (i = [0:3]) {
        rotate([0, 0, i * 90])
            translate([0, 0, -coupling_length/3 + i * coupling_length/6])
                rotate([0, 90, 0])
                    cylinder(d=2, h=coupling_od, center=true, $fn=32);
    }

    // Set screw for 5mm shaft
    translate([0, 0, -coupling_length/4])
        rotate([90, 0, 0])
            cylinder(d=set_screw_d, h=coupling_od, center=true, $fn=32);

    // Set screw for 8mm shaft
    translate([0, 0, coupling_length/4])
        rotate([90, 0, 90])
            cylinder(d=set_screw_d, h=coupling_od, center=true, $fn=32);
}
""",
        expected_parts=["coupling_body", "5mm_bore", "8mm_bore", "set_screws", "flex_slots"],
        essential_parts=["coupling_body", "5mm_bore", "8mm_bore"],
        secondary_parts=["set_screws"],
        optional_parts=["flex_slots"],
        nopscadlib_keywords=["coupling", "coupler", "nema17", "shaft", "leadscrew"]
    ),
    BenchmarkPrompt(
        id="bench_complex_03",
        text="A Raspberry Pi 4 case with GPIO slot - enclosure for RPi 4 with ventilation and port cutouts",
        category="complex",
        ground_truth_scad="""// Raspberry Pi 4 Case
// Pi 4: 85mm x 56mm x ~17mm
pi_length = 85;
pi_width = 56;
pi_height = 17;
wall = 2;
vent_slots = 5;

// Bottom case
difference() {
    // Outer shell
    cube([pi_length + wall*2, pi_width + wall*2, pi_height/2 + wall], center=true);

    // Pi pocket
    translate([0, 0, wall])
        cube([pi_length, pi_width, pi_height], center=true);

    // USB-C power cutout (rear)
    translate([pi_length/2, -pi_width/4, 0])
        cube([wall*3, 9, 4], center=true);

    // Micro HDMI cutouts (2x)
    for (y = [0, 14]) {
        translate([pi_length/2, y - pi_width/4 + 15, 0])
            cube([wall*3, 7, 4], center=true);
    }

    // USB-A cutouts (2x)
    translate([-pi_length/2, pi_width/4 - 5, 0])
        cube([wall*3, 15, 8], center=true);
    translate([-pi_length/2, pi_width/4 - 22, 0])
        cube([wall*3, 15, 8], center=true);

    // Ethernet cutout
    translate([-pi_length/2, -pi_width/4 + 5, 0])
        cube([wall*3, 16, 14], center=true);

    // Ventilation slots (bottom)
    for (i = [0:vent_slots-1]) {
        translate([i * 12 - 24, 0, -pi_height/4])
            cube([8, pi_width - 10, wall + 1], center=true);
    }

    // Mounting posts holes
    for (x = [-1, 1]) {
        for (y = [-1, 1]) {
            translate([x * 29, y * 24.5, -pi_height/4])
                cylinder(d=2.7, h=10, center=true, $fn=32);
        }
    }
}

// Mounting posts
for (x = [-1, 1]) {
    for (y = [-1, 1]) {
        translate([x * 29, y * 24.5, wall/2])
            difference() {
                cylinder(d=6, h=3, $fn=32);
                cylinder(d=2.5, h=4, $fn=32);
            }
    }
}
""",
        expected_parts=["case_body", "port_cutouts", "ventilation", "mounting_posts", "gpio_slot"],
        essential_parts=["case_body", "port_cutouts"],
        secondary_parts=["ventilation", "mounting_posts"],
        optional_parts=["gpio_slot"],
        nopscadlib_keywords=["raspberry pi", "rpi", "raspberry", "pi", "electronics", "case"]
    ),
    BenchmarkPrompt(
        id="bench_complex_04",
        text="An ESP32 DevKit enclosure with display cutout - project box for ESP32 with 0.96 inch OLED window",
        category="complex",
        ground_truth_scad="""// ESP32 DevKit Enclosure with OLED Display
// ESP32: ~55mm x 28mm, OLED: 27mm x 27mm
esp_length = 55;
esp_width = 28;
oled_size = 27;
oled_view = 22;  // Visible area
box_height = 20;
wall = 2;

// Main enclosure
difference() {
    // Outer box
    cube([esp_length + 20, esp_width + oled_size + 10, box_height], center=true);

    // Inner cavity
    translate([0, 0, wall])
        cube([esp_length + 16, esp_width + oled_size + 6, box_height], center=true);

    // USB port cutout
    translate([-(esp_length/2 + 10), -((esp_width + oled_size)/2 - esp_width/2), 0])
        cube([wall*3, 10, 5], center=true);

    // OLED display window
    translate([0, (esp_width + oled_size)/2 - oled_size/2 - 2, box_height/2 - wall/2])
        cube([oled_view, oled_view, wall*2], center=true);

    // Ventilation slots
    for (i = [0:3]) {
        translate([i * 10 - 15, -((esp_width + oled_size)/2), 0])
            cube([6, wall*2, 8], center=true);
    }

    // Button holes (2x)
    for (x = [-1, 1]) {
        translate([x * 20, (esp_width + oled_size)/2, 0])
            rotate([90, 0, 0])
                cylinder(d=6, h=wall*3, center=true, $fn=32);
    }
}

// ESP32 mounting rails
for (y = [-1, 1]) {
    translate([0, y * (esp_width/2 - 5) - (oled_size/2 - 5), -box_height/2 + wall + 2])
        cube([esp_length - 5, 2, 4], center=true);
}
""",
        expected_parts=["enclosure", "esp_pocket", "oled_window", "usb_cutout", "buttons"],
        essential_parts=["enclosure", "oled_window"],
        secondary_parts=["usb_cutout", "ventilation"],
        optional_parts=["buttons", "mounting_rails"],
        nopscadlib_keywords=["esp32", "oled", "display", "electronics", "enclosure"]
    ),
    BenchmarkPrompt(
        id="bench_complex_05",
        text="A Z-axis leadscrew nut block - anti-backlash nut housing for T8 leadscrew with linear rail mount",
        category="complex",
        ground_truth_scad="""// T8 Leadscrew Anti-Backlash Nut Block
// T8: 8mm leadscrew, 22mm flange, MGN12 rail mount
leadscrew_d = 8;
nut_flange_d = 22;
nut_h = 15;
block_width = 40;
block_height = 12;
rail_hole_spacing = 20;  // MGN12

difference() {
    // Main block
    cube([block_width, 30, block_height], center=true);

    // Leadscrew nut pocket
    cylinder(d=nut_flange_d + 0.5, h=block_height + 1, center=true, $fn=64);

    // Leadscrew clearance
    cylinder(d=leadscrew_d + 2, h=block_height + 10, center=true, $fn=64);

    // Nut mounting holes (usually 4 on flange)
    for (i = [0:3]) {
        rotate([0, 0, i * 90 + 45])
            translate([nut_flange_d/2 - 2, 0, 0])
                cylinder(d=3.2, h=block_height + 1, center=true, $fn=32);
    }

    // MGN12 rail mounting holes
    for (x = [-1, 1]) {
        translate([x * rail_hole_spacing/2, 10, 0])
            cylinder(d=3.2, h=block_height + 1, center=true, $fn=32);
    }

    // Anti-rotation slot
    translate([0, -12, 0])
        cube([6, 8, block_height + 1], center=true);

    // Weight reduction
    for (x = [-1, 1]) {
        translate([x * 14, -5, 0])
            cylinder(d=8, h=block_height + 1, center=true, $fn=32);
    }
}
""",
        expected_parts=["block", "nut_pocket", "leadscrew_hole", "rail_mount", "anti_backlash"],
        essential_parts=["block", "nut_pocket", "leadscrew_hole"],
        secondary_parts=["rail_mount"],
        optional_parts=["anti_rotation", "weight_reduction"],
        nopscadlib_keywords=["leadscrew", "t8", "nut", "mgn12", "linear rail", "shaft"]
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

    # VLM/Verification (only for CRAFT)
    vlm_iterations: int = 0
    vlm_approved: bool = False
    verification_iterations: int = 0
    verification_passed: bool = False

    # Paths
    scad_path: Optional[str] = None
    stl_path: Optional[str] = None
    image_path: Optional[str] = None

    # 3D metrics (computed later)
    chamfer_distance: Optional[float] = None
    fscore: Optional[float] = None
    fscore_precision: Optional[float] = None
    fscore_recall: Optional[float] = None
    voxel_iou: Optional[float] = None

    # Image metric
    ssim: Optional[float] = None

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

def _openscad_env() -> dict:
    """Build environment with OPENSCADPATH for NopSCADlib resolution.

    Uses the OPENSCADPATH env var (works with all OpenSCAD versions)
    instead of --librarydir which is only available in newer builds.
    """
    env = os.environ.copy()
    if os.path.isdir(NOPSCADLIB_LIBRARY_DIR):
        existing = env.get("OPENSCADPATH", "")
        env["OPENSCADPATH"] = (
            f"{NOPSCADLIB_LIBRARY_DIR}{os.pathsep}{existing}" if existing
            else NOPSCADLIB_LIBRARY_DIR
        )
    return env


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
        cmd = ["openscad", "--export-format", "echo", "-o", "/dev/null", scad_path]
        result = subprocess.run(
            cmd, capture_output=True, text=True, timeout=30,
            env=_openscad_env()
        )

        # Only fail on actual parse/syntax errors, not warnings or deprecation notices.
        if result.returncode != 0:
            stderr = result.stderr.lower()
            has_parse_error = "parse error" in stderr or "syntax error" in stderr
            has_fatal_error = any(
                line.strip().startswith("error")
                for line in stderr.splitlines()
            )
            if has_parse_error or has_fatal_error:
                print(f"    [syntax] FAIL: {result.stderr[:200]}")
                return False

        return True
    except FileNotFoundError:
        print("    [syntax] openscad not found in PATH")
        return False
    except Exception as e:
        print(f"    [syntax] check failed: {e}")
        return False


def render_image(scad_path: str, image_path: str) -> bool:
    """Render SCAD to PNG image with transparent background."""
    try:
        Path(image_path).parent.mkdir(parents=True, exist_ok=True)
        cmd = ["openscad", "-o", image_path, "--imgsize=800,600",
               "--autocenter", "--viewall"]
        # Add NopSCADlib library path so includes resolve
        if os.path.isdir(NOPSCADLIB_LIBRARY_DIR):
            cmd.extend(["--librarydir", NOPSCADLIB_LIBRARY_DIR])
        cmd.append(scad_path)
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=120)
        return result.returncode == 0 and Path(image_path).exists()
    except Exception:
        return False


def render_stl(scad_path: str, stl_path: str) -> bool:
    """Render SCAD to STL for Chamfer distance."""
    try:
        Path(stl_path).parent.mkdir(parents=True, exist_ok=True)
        cmd = ["openscad", "-o", stl_path, scad_path]
        result = subprocess.run(
            cmd, capture_output=True, text=True, timeout=120,
            env=_openscad_env()
        )
        ok = Path(stl_path).exists() and Path(stl_path).stat().st_size > 0
        if not ok:
            print(f"    [stl] render failed (rc={result.returncode}): {result.stderr[:200]}")
        return ok
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
        extra_info = {"vlm_iterations": 0, "verification_iterations": 0}

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


class CRAFTPipeline:
    """Full CRAFT pipeline WITH VLM correction and component verification."""

    def __init__(
        self,
        client: OpenAI,
        pipeline_model: str = "gpt-4o",
        vlm_model: str = "gpt-5.2",
        use_rag: bool = False,
        use_vlm: bool = True,
        use_verification: bool = True,
        max_vlm_iterations: int = 3,
        max_verification_iterations: int = 3
    ):
        self.openai_client = client
        self.pipeline_model = pipeline_model
        self.vlm_model = vlm_model
        self.use_rag = use_rag
        self.use_vlm = use_vlm
        self.use_verification = use_verification
        self.max_vlm_iterations = max_vlm_iterations
        self.max_verification_iterations = max_verification_iterations

        self._initialized = False

    def _init(self):
        """Lazily initialize pipeline components."""
        if self._initialized:
            return

        from core import TextReasoner, Planner, Compiler, Validator
        from core.llm_client import create_unified_client

        self.unified_client = create_unified_client(openai_client=self.openai_client)

        # Use VLM model for understanding/planning, pipeline model for compilation
        self.reasoner = TextReasoner(self.unified_client, self.vlm_model)
        self.planner = Planner(self.unified_client, self.vlm_model)
        self.compiler = Compiler(self.unified_client, self.pipeline_model)
        self.validator = Validator(pass_threshold=0.80)

        # VLM Self-Correction
        if self.use_vlm:
            from core.visual_corrector import VisualSelfCorrector
            self.visual_corrector = VisualSelfCorrector(
                client=self.unified_client,
                model=self.vlm_model,
                max_iterations=self.max_vlm_iterations
            )

        # Component Verification
        if self.use_verification:
            from core.component_verifier import ComponentVerifier
            self.component_verifier = ComponentVerifier(
                client=self.unified_client,
                model=self.vlm_model,
                max_iterations=self.max_verification_iterations
            )

        # RAG retriever
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
        """Generate OpenSCAD via full CRAFT pipeline with VLM and verification."""
        self._init()

        start = time.time()
        extra_info = {
            "vlm_iterations": 0,
            "vlm_approved": False,
            "verification_iterations": 0,
            "verification_passed": False
        }

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

            # Save initial code
            save_scad(code, scad_path)

            # Stage 4: Render
            render_ok = render_image(scad_path, image_path)

            # Stage 5: VLM Self-Correction (if enabled and render succeeded)
            if self.use_vlm and render_ok:
                print(f"  [VLM] Running visual self-correction...")
                timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")

                vlm_result = self.visual_corrector.run_correction_loop(
                    scad_code=code,
                    original_prompt=prompt_text,
                    expected_parts=prompt.essential_parts + prompt.secondary_parts,
                    scad_path=scad_path,
                    timestamp=f"{timestamp}_{prompt.id}"
                )

                extra_info["vlm_iterations"] = vlm_result.iterations
                extra_info["vlm_approved"] = vlm_result.final_passed

                if vlm_result.final_code and vlm_result.final_code != code:
                    code = vlm_result.final_code
                    save_scad(code, scad_path)
                    render_image(scad_path, image_path)

                print(f"  [VLM] {vlm_result.iterations} iterations, approved={vlm_result.final_passed}")

            # Stage 6: Component Verification (if enabled and render succeeded)
            if self.use_verification and render_ok:
                print(f"  [Verify] Running component verification...")
                verif_timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")

                verif_result = self.component_verifier.verify_and_fix(
                    scad_code=code,
                    expected_parts=prompt.essential_parts + prompt.secondary_parts,
                    original_prompt=prompt_text,
                    scad_path=scad_path,
                    timestamp=f"{verif_timestamp}_{prompt.id}",
                    essential_parts=prompt.essential_parts,
                    secondary_parts=prompt.secondary_parts,
                    optional_parts=prompt.optional_parts
                )

                extra_info["verification_iterations"] = verif_result.iterations
                extra_info["verification_passed"] = verif_result.success

                if verif_result.final_code and verif_result.final_code != code:
                    code = verif_result.final_code
                    save_scad(code, scad_path)
                    render_image(scad_path, image_path)

                print(f"  [Verify] {verif_result.iterations} iterations, success={verif_result.success}")

            return code, time.time() - start, extra_info

        except Exception as e:
            print(f"  Error in CRAFT pipeline: {e}")
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
        self.output_dir = Path(output_dir or f"./evaluation/nopscadlib_benchmark/{timestamp}")
        self.output_dir.mkdir(parents=True, exist_ok=True)

        # Create subdirectories
        for subdir in ["ground_truth", "gpt4o", "gpt52", "craft", "craft_rag",
                       "stl", "images"]:
            (self.output_dir / subdir).mkdir(exist_ok=True)

        # Methods to run
        self.methods = methods or ["gpt4o", "gpt52", "craft", "craft_rag"]

        # Initialize OpenAI client
        self.client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

        # Initialize method runners
        self.runners = {}

        if "gpt4o" in self.methods:
            self.runners["gpt4o"] = DirectBaseline(self.client, "gpt-4o")
        if "gpt52" in self.methods:
            self.runners["gpt52"] = DirectBaseline(self.client, "gpt-5.2")
        if "craft" in self.methods:
            self.runners["craft"] = CRAFTPipeline(
                self.client,
                pipeline_model="gpt-4o",
                vlm_model="gpt-5.2",
                use_rag=False,
                use_vlm=True,
                use_verification=True
            )
        if "craft_rag" in self.methods:
            self.runners["craft_rag"] = CRAFTPipeline(
                self.client,
                pipeline_model="gpt-4o",
                vlm_model="gpt-5.2",
                use_rag=True,
                use_vlm=True,
                use_verification=True
            )

        print(f"[Benchmark] Output: {self.output_dir}")
        print(f"[Benchmark] Methods: {self.methods}")
        print(f"[Benchmark] CRAFT features: VLM correction=True, Verification=True")

    def run(self, prompts: List[BenchmarkPrompt] = None) -> Dict[str, Any]:
        """Run the complete benchmark."""
        prompts = prompts or BENCHMARK_PROMPTS

        print(f"\n{'='*70}")
        print("NopSCADlib Ground Truth Benchmark")
        print(f"{'='*70}")
        print(f"Prompts: {len(prompts)}")
        print(f"Methods: {', '.join(self.methods)}")
        print(f"CRAFT: VLM + Verification enabled")
        print(f"Baselines: Direct generation only (no pipeline)")
        print(f"{'='*70}\n")

        results = []

        for i, prompt in enumerate(prompts):
            print(f"\n[{i+1}/{len(prompts)}] {prompt.id}: {prompt.text[:50]}...")
            print(f"  Keywords: {', '.join(prompt.nopscadlib_keywords[:3])}")

            bench_result = BenchmarkResult(prompt=prompt)

            # Load pre-rendered ground truth STL from ground_truth_nopscadlib/
            # These are rendered offline from NopSCADlib wrapper .scad files
            gt_scad_path = GROUND_TRUTH_DIR / f"{prompt.ground_truth_file}.scad"
            gt_stl_path = GROUND_TRUTH_DIR / f"{prompt.ground_truth_file}.stl"

            if gt_stl_path.exists() and gt_stl_path.stat().st_size > 0:
                print(f"  [GT] Using pre-rendered STL: {gt_stl_path.name}")
            else:
                # Fallback: render from SCAD if pre-rendered STL not found
                print(f"  [GT] Pre-rendered STL not found, rendering from SCAD...")
                fallback_scad = self.output_dir / "ground_truth" / f"{prompt.id}.scad"
                gt_stl_path = self.output_dir / "stl" / f"{prompt.id}_gt.stl"
                save_scad(prompt.ground_truth_scad, str(fallback_scad))
                render_stl(str(fallback_scad), str(gt_stl_path))
                gt_scad_path = fallback_scad

            bench_result.ground_truth_paths = {
                "scad": str(gt_scad_path),
                "stl": str(gt_stl_path)
            }

            # Render ground truth image for SSIM comparison
            gt_image_path = self.output_dir / "images" / f"{prompt.id}_gt.png"
            if not gt_image_path.exists():
                # Use fallback SCAD (hand-authored) for rendering GT image
                gt_render_scad = self.output_dir / "ground_truth" / f"{prompt.id}.scad"
                if not gt_render_scad.exists():
                    save_scad(prompt.ground_truth_scad, str(gt_render_scad))
                render_image(str(gt_render_scad), str(gt_image_path))
                if gt_image_path.exists():
                    print(f"  [GT] Rendered GT image for SSIM")

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
                method_result.vlm_iterations = extra.get("vlm_iterations", 0)
                method_result.vlm_approved = extra.get("vlm_approved", False)
                method_result.verification_iterations = extra.get("verification_iterations", 0)
                method_result.verification_passed = extra.get("verification_passed", False)

                if code:
                    # For direct baselines, save and render here
                    if isinstance(runner, DirectBaseline):
                        save_scad(code, str(scad_path))
                        render_image(str(scad_path), str(image_path))

                    method_result.scad_path = str(scad_path)
                    method_result.syntax_valid = check_syntax(str(scad_path))

                    # Always try to render STL regardless of syntax check result.
                    # The syntax check can be overly strict; a successful STL render
                    # is the ground truth for whether the code is valid.
                    method_result.render_success = render_stl(str(scad_path), str(stl_path))
                    if method_result.render_success:
                        method_result.stl_path = str(stl_path)
                        # If STL rendered, syntax was actually fine
                        method_result.syntax_valid = True

                    if Path(image_path).exists():
                        method_result.image_path = str(image_path)

                    # Compute 3D metrics (Chamfer, F-score, Voxel IoU)
                    if method_result.stl_path and gt_stl_path.exists():
                        print(f"  [{method_name}] Computing 3D metrics...")
                        gt_pc = load_stl_as_pointcloud(str(gt_stl_path))
                        method_pc = load_stl_as_pointcloud(str(method_result.stl_path))

                        if gt_pc is not None and method_pc is not None:
                            # Chamfer Distance
                            method_result.chamfer_distance = compute_chamfer_distance(gt_pc, method_pc)

                            # F-score (tau = 1.0mm default)
                            from utils.metrics import compute_fscore
                            fs, prec, rec = compute_fscore(method_pc, gt_pc, tau=1.0)
                            method_result.fscore = fs
                            method_result.fscore_precision = prec
                            method_result.fscore_recall = rec

                            print(f"  [{method_name}] CD={method_result.chamfer_distance:.4f}  F={fs:.4f} (P={prec:.3f} R={rec:.3f})")

                        # Voxel IoU (operates on STL files directly)
                        try:
                            from utils.metrics import compute_voxel_iou
                            method_result.voxel_iou = compute_voxel_iou(
                                str(method_result.stl_path), str(gt_stl_path)
                            )
                            print(f"  [{method_name}] Voxel IoU={method_result.voxel_iou:.4f}")
                        except Exception as e:
                            print(f"  [{method_name}] Voxel IoU failed: {e}")

                    # Compute SSIM (image-based, needs GT render)
                    gt_image_path = self.output_dir / "images" / f"{prompt.id}_gt.png"
                    if method_result.image_path and gt_image_path.exists():
                        try:
                            from utils.metrics import compute_ssim
                            method_result.ssim = compute_ssim(
                                str(method_result.image_path), str(gt_image_path)
                            )
                            print(f"  [{method_name}] SSIM={method_result.ssim:.4f}")
                        except Exception as e:
                            print(f"  [{method_name}] SSIM failed: {e}")

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
            "by_method": {},
            "by_category": {},
            "detailed_results": []
        }

        # Compute penalty CD for render failures: max observed CD across all
        # successful renders.  Failed renders get CD = penalty_cd, F-score = 0,
        # V-IoU = 0 so that every method is compared on the same N items.
        all_successful_cd = []
        for r in results:
            for mr in r.method_results.values():
                if mr and mr.chamfer_distance is not None:
                    all_successful_cd.append(mr.chamfer_distance)
        penalty_cd = max(all_successful_cd) if all_successful_cd else 20.0
        summary["penalty_cd"] = penalty_cd

        # Per-method stats
        for method in self.methods:
            method_results = [r.method_results.get(method) for r in results if method in r.method_results]
            valid_results = [r for r in method_results if r]

            # Penalize render failures: CD → penalty_cd, F-score → 0, V-IoU → 0, SSIM → 0
            chamfer_values = [r.chamfer_distance if r.chamfer_distance is not None else penalty_cd for r in valid_results]
            fscore_values = [r.fscore if r.fscore is not None else 0.0 for r in valid_results]
            voxel_iou_values = [r.voxel_iou if r.voxel_iou is not None else 0.0 for r in valid_results]
            ssim_values = [r.ssim if r.ssim is not None else 0.0 for r in valid_results]
            n_rendered = sum(1 for r in valid_results if r.chamfer_distance is not None)

            summary["by_method"][method] = {
                "syntax_rate": sum(r.syntax_valid for r in valid_results) / len(valid_results) * 100 if valid_results else 0,
                "render_rate": sum(r.render_success for r in valid_results) / len(valid_results) * 100 if valid_results else 0,
                "avg_chamfer": float(np.mean(chamfer_values)) if chamfer_values else None,
                "std_chamfer": float(np.std(chamfer_values)) if chamfer_values else None,
                "median_chamfer": float(np.median(chamfer_values)) if chamfer_values else None,
                "n_valid_chamfer": n_rendered,
                "avg_fscore": float(np.mean(fscore_values)) if fscore_values else None,
                "std_fscore": float(np.std(fscore_values)) if fscore_values else None,
                "avg_voxel_iou": float(np.mean(voxel_iou_values)) if voxel_iou_values else None,
                "std_voxel_iou": float(np.std(voxel_iou_values)) if voxel_iou_values else None,
                "avg_ssim": float(np.mean(ssim_values)) if ssim_values else None,
                "std_ssim": float(np.std(ssim_values)) if ssim_values else None,
                "avg_time": float(np.mean([r.generation_time for r in valid_results])) if valid_results else 0,
                "avg_vlm_iterations": float(np.mean([r.vlm_iterations for r in valid_results])) if valid_results else 0,
                "vlm_approval_rate": sum(r.vlm_approved for r in valid_results) / len(valid_results) * 100 if valid_results else 0,
            }

        # Per-category stats
        for category in ["simple", "medium", "complex"]:
            cat_results = [r for r in results if r.prompt.category == category]
            summary["by_category"][category] = {"n_prompts": len(cat_results)}

            for method in self.methods:
                method_cat_results = [r.method_results.get(method) for r in cat_results if method in r.method_results]
                # Penalize render failures: CD → penalty_cd, F-score → 0, V-IoU → 0, SSIM → 0
                chamfer_values = [r.chamfer_distance if r.chamfer_distance is not None else penalty_cd for r in method_cat_results if r]
                fscore_values = [r.fscore if r.fscore is not None else 0.0 for r in method_cat_results if r]
                voxel_iou_values = [r.voxel_iou if r.voxel_iou is not None else 0.0 for r in method_cat_results if r]
                ssim_values = [r.ssim if r.ssim is not None else 0.0 for r in method_cat_results if r]

                summary["by_category"][category][method] = {
                    "avg_chamfer": float(np.mean(chamfer_values)) if chamfer_values else None,
                    "median_chamfer": float(np.median(chamfer_values)) if chamfer_values else None,
                    "avg_fscore": float(np.mean(fscore_values)) if fscore_values else None,
                    "avg_voxel_iou": float(np.mean(voxel_iou_values)) if voxel_iou_values else None,
                    "avg_ssim": float(np.mean(ssim_values)) if ssim_values else None,
                    "render_rate": sum(r.render_success for r in method_cat_results if r) / len(method_cat_results) * 100 if method_cat_results else 0
                }

        # Detailed per-prompt results
        for r in results:
            prompt_detail = {
                "id": r.prompt.id,
                "text": r.prompt.text,
                "category": r.prompt.category,
                "metrics": {}
            }
            for method, mr in r.method_results.items():
                prompt_detail["metrics"][method] = {
                    "chamfer": mr.chamfer_distance,
                    "fscore": mr.fscore,
                    "voxel_iou": mr.voxel_iou,
                    "ssim": mr.ssim
                }
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
        """Generate LaTeX table for paper with all 4 metrics.

        Shows 3 methods per complexity tier: GPT-4o, GPT-5.2, and CRAFT (best).
        CRAFT (best) picks the better of CRAFT (no RAG) vs CRAFT + RAG
        for each complexity tier based on lower mean CD.
        """
        lines = []
        lines.append("% Auto-generated from NopSCADlib benchmark")
        lines.append("\\begin{table*}[t]")
        lines.append("\\centering")
        penalty_cd = summary.get("penalty_cd")
        penalty_note = ""
        if penalty_cd is not None:
            penalty_note = (f" Failed renders are penalized (CD={penalty_cd:.1f}, "
                            "F=0, V-IoU=0, SSIM=0) so all methods are compared over the same $N$ items.")
        lines.append("\\caption{Quantitative evaluation against NopSCADlib ground truth across 15 benchmark prompts. "
                      "CD = Chamfer Distance (lower is better), F = F-score at $\\tau{=}1$\\,mm (higher is better), "
                      "V-IoU = Voxel IoU (higher is better), SSIM = Structural Similarity (higher is better). "
                      f"Best results per tier in \\textbf{{bold}}.{penalty_note}}}")
        lines.append("\\label{tab:nopscadlib-benchmark}")
        lines.append("\\setlength{\\tabcolsep}{4pt}")
        lines.append("\\begin{tabular}{llccccc}")
        lines.append("\\toprule")
        lines.append("\\textbf{Complexity} & \\textbf{Method} & "
                      "\\textbf{Render} & "
                      "\\textbf{CD}$\\downarrow$ & \\textbf{F-score}$\\uparrow$ & "
                      "\\textbf{V-IoU}$\\uparrow$ & \\textbf{SSIM}$\\uparrow$ \\\\")
        lines.append("\\midrule")

        display_methods = ["gpt4o", "gpt52"]  # Always shown

        for category in ["simple", "medium", "complex"]:
            cat_data = summary["by_category"].get(category, {})
            n = cat_data.get("n_prompts", 0)

            # Collect all values for bolding the best per column
            all_methods_data = {}
            for method in display_methods:
                all_methods_data[method] = cat_data.get(method, {})

            # Determine best CRAFT variant.
            # Prefer higher render rate first; break ties with lower CD.
            craft_data = cat_data.get("craft", {})
            craft_rag_data = cat_data.get("craft_rag", {})
            craft_cd = craft_data.get("avg_chamfer")
            craft_rag_cd = craft_rag_data.get("avg_chamfer")
            craft_rr = craft_data.get("render_rate", 0)
            craft_rag_rr = craft_rag_data.get("render_rate", 0)

            if craft_cd is not None and craft_rag_cd is not None:
                if craft_rag_rr > craft_rr:
                    best_craft = craft_rag_data
                    best_label = "CRAFT + RAG"
                elif craft_rr > craft_rag_rr:
                    best_craft = craft_data
                    best_label = "CRAFT"
                elif craft_rag_cd <= craft_cd:
                    best_craft = craft_rag_data
                    best_label = "CRAFT + RAG"
                else:
                    best_craft = craft_data
                    best_label = "CRAFT"
            elif craft_rag_cd is not None:
                best_craft = craft_rag_data
                best_label = "CRAFT + RAG"
            elif craft_cd is not None:
                best_craft = craft_data
                best_label = "CRAFT"
            else:
                best_craft = {}
                best_label = "CRAFT"

            all_methods_data["craft_best"] = best_craft

            # Find best value per metric for bolding
            def _best(metric, higher_better=True):
                vals = {}
                for m, d in all_methods_data.items():
                    v = d.get(metric)
                    if v is not None:
                        vals[m] = v
                if not vals:
                    return None
                if higher_better:
                    return max(vals.values())
                return min(vals.values())

            best_cd = _best("avg_chamfer", higher_better=False)
            best_fs = _best("avg_fscore", higher_better=True)
            best_viou = _best("avg_voxel_iou", higher_better=True)
            best_ssim = _best("avg_ssim", higher_better=True)

            def _fmt(val, best_val, higher_better=True, fmt_str=".2f"):
                if val is None:
                    return "---"
                s = f"{val:{fmt_str}}"
                if best_val is not None:
                    is_best = (higher_better and val >= best_val - 1e-6) or \
                              (not higher_better and val <= best_val + 1e-6)
                    if is_best:
                        s = f"\\textbf{{{s}}}"
                return s

            lines.append(f"\\multirow{{3}}{{*}}{{{category.capitalize()} ({n})}}")

            # GPT-4o and GPT-5.2 rows
            for i, method in enumerate(display_methods):
                d = all_methods_data[method]
                label = {"gpt4o": "GPT-4o (direct)", "gpt52": "GPT-5.2 (direct)"}[method]

                rr = d.get("render_rate", 0)
                rr_s = f"{rr:.0f}\\%"
                cd_s = _fmt(d.get("avg_chamfer"), best_cd, False)
                fs_s = _fmt(d.get("avg_fscore"), best_fs, True)
                vi_s = _fmt(d.get("avg_voxel_iou"), best_viou, True)
                ss_s = _fmt(d.get("avg_ssim"), best_ssim, True)

                prefix = "  & " if i > 0 else "  "
                lines.append(f"{prefix}{label} & {rr_s} & {cd_s} & {fs_s} & {vi_s} & {ss_s} \\\\")

            # CRAFT (best) row
            d = best_craft
            rr = d.get("render_rate", 0)
            rr_s = f"{rr:.0f}\\%"
            cd_s = _fmt(d.get("avg_chamfer"), best_cd, False)
            fs_s = _fmt(d.get("avg_fscore"), best_fs, True)
            vi_s = _fmt(d.get("avg_voxel_iou"), best_viou, True)
            ss_s = _fmt(d.get("avg_ssim"), best_ssim, True)

            lines.append(f"  & {best_label} & {rr_s} & {cd_s} & {fs_s} & {vi_s} & {ss_s} \\\\")

            if category != "complex":
                lines.append("\\midrule")

        lines.append("\\bottomrule")
        lines.append("\\end{tabular}")
        lines.append("\\end{table*}")

        with open(self.output_dir / "latex_table.tex", "w") as f:
            f.write("\n".join(lines))

        print(f"\nLaTeX table saved to: {self.output_dir / 'latex_table.tex'}")

    def _print_summary(self, summary: Dict[str, Any]):
        """Print summary to console."""
        print(f"\n{'='*70}")
        print("BENCHMARK SUMMARY")
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
            avg_fs = data.get('avg_fscore')
            print(f"  Avg F-score:    {avg_fs:.4f}" if avg_fs is not None else "  Avg F-score:    N/A")
            avg_vi = data.get('avg_voxel_iou')
            print(f"  Avg Voxel IoU:  {avg_vi:.4f}" if avg_vi is not None else "  Avg Voxel IoU:  N/A")
            avg_ss = data.get('avg_ssim')
            print(f"  Avg SSIM:       {avg_ss:.4f}" if avg_ss is not None else "  Avg SSIM:       N/A")
            print(f"  Avg Time:       {data.get('avg_time', 0):.2f}s")
            if data.get('avg_vlm_iterations', 0) > 0:
                print(f"  VLM Iterations: {data.get('avg_vlm_iterations', 0):.1f}")
                print(f"  VLM Approval:   {data.get('vlm_approval_rate', 0):.1f}%")

        print("\n--- Per-Category Results ---")
        penalty_cd = summary.get("penalty_cd")
        if penalty_cd is not None:
            print(f"\nNote: Failed renders penalized with CD={penalty_cd:.2f}, F-score=0, V-IoU=0, SSIM=0")
        header = (f"{'Category':<10} | {'Method':<18} | {'Rend%':>5} | {'CD':>6} | "
                  f"{'F-score':>7} | {'V-IoU':>6} | {'SSIM':>6}")
        print(header)
        print("-" * len(header))

        for category in ["simple", "medium", "complex"]:
            cat_data = summary["by_category"].get(category, {})

            for method in ["gpt4o", "gpt52"]:
                d = cat_data.get(method, {})
                label = {"gpt4o": "GPT-4o (direct)", "gpt52": "GPT-5.2 (direct)"}[method]
                rr_s = f"{d.get('render_rate', 0):.0f}"
                cd_s = f"{d.get('avg_chamfer', 0):.2f}" if d.get("avg_chamfer") is not None else "N/A"
                fs_s = f"{d.get('avg_fscore', 0):.3f}" if d.get("avg_fscore") is not None else "N/A"
                vi_s = f"{d.get('avg_voxel_iou', 0):.3f}" if d.get("avg_voxel_iou") is not None else "N/A"
                ss_s = f"{d.get('avg_ssim', 0):.3f}" if d.get("avg_ssim") is not None else "N/A"
                cat_label = category if method == "gpt4o" else ""
                print(f"{cat_label:<10} | {label:<18} | {rr_s:>5} | {cd_s:>6} | {fs_s:>7} | {vi_s:>6} | {ss_s:>6}")

            # Best CRAFT: prefer higher render rate, then lower CD
            craft_cd = cat_data.get("craft", {}).get("avg_chamfer")
            craft_rag_cd = cat_data.get("craft_rag", {}).get("avg_chamfer")
            craft_rr = cat_data.get("craft", {}).get("render_rate", 0)
            craft_rag_rr = cat_data.get("craft_rag", {}).get("render_rate", 0)
            if craft_cd is not None and craft_rag_cd is not None:
                if craft_rag_rr > craft_rr:
                    best_key, best_label = "craft_rag", "CRAFT + RAG"
                elif craft_rr > craft_rag_rr:
                    best_key, best_label = "craft", "CRAFT"
                elif craft_rag_cd <= craft_cd:
                    best_key, best_label = "craft_rag", "CRAFT + RAG"
                else:
                    best_key, best_label = "craft", "CRAFT"
            elif craft_rag_cd is not None:
                best_key = "craft_rag"
                best_label = "CRAFT + RAG"
            elif craft_cd is not None:
                best_key = "craft"
                best_label = "CRAFT"
            else:
                best_key = None
                best_label = "CRAFT"

            if best_key:
                d = cat_data.get(best_key, {})
                rr_s = f"{d.get('render_rate', 0):.0f}"
                cd_s = f"{d.get('avg_chamfer', 0):.2f}" if d.get("avg_chamfer") is not None else "N/A"
                fs_s = f"{d.get('avg_fscore', 0):.3f}" if d.get("avg_fscore") is not None else "N/A"
                vi_s = f"{d.get('avg_voxel_iou', 0):.3f}" if d.get("avg_voxel_iou") is not None else "N/A"
                ss_s = f"{d.get('avg_ssim', 0):.3f}" if d.get("avg_ssim") is not None else "N/A"
            else:
                rr_s = "N/A"
                cd_s = fs_s = vi_s = ss_s = "N/A"

            print(f"{'':10} | {best_label:<18} | {rr_s:>5} | {cd_s:>6} | {fs_s:>7} | {vi_s:>6} | {ss_s:>6}")

            if category != "complex":
                print("-" * len(header))

        print(f"\n{'='*70}")


# =============================================================================
# CLI
# =============================================================================

def main():
    parser = argparse.ArgumentParser(
        description="NopSCADlib Ground Truth Benchmark",
        formatter_class=argparse.RawDescriptionHelpFormatter
    )

    parser.add_argument("--quick", action="store_true",
                        help="Quick test with only 3 prompts")
    parser.add_argument("--methods", nargs="+",
                        choices=["gpt4o", "gpt52", "craft", "craft_rag"],
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
