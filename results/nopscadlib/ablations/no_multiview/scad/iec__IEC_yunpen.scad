// Parameters
overall_width = 40; //[20:80:0.5]
overall_height = 29; //[14.5:58:0.5]
cutout_clearance = 0.2; //[0:1:0.05]
screw_hole_diameter = 3.2; //[2:6:0.1]
screw_hole_pitch_x = 30; //[20:50:0.5]
screw_hole_pitch_y = 0; //[0:20:0.5]
flange_thickness = 2.5; //[1.2:5:0.1]
bezel_thickness = 2; //[1:4:0.1]
body_depth = 28; //[15:60:0.5]
corner_radius = 3; //[0.5:8:0.25]
filter_can_enabled = 1; //[0:1:1]
terminal_spade_width = 6.3; //[2.8:9.5:0.1]
terminal_spade_thickness = 0.8; //[0.5:1.5:0.05]
terminal_spade_length = 12; //[6:25:0.5]
terminal_spade_pitch_x = 14; //[10:20:0.5]
terminal_spade_pitch_y = 6; //[4:12:0.5]
orifice_width = 24.5; //[18:30:0.5]
orifice_height = 16.3; //[12:22:0.5]
orifice_depth = 17; //[10:25:0.5]
body_width = 30; //[20:38:0.5]
body_height = 22; //[16:28:0.5]
filter_can_width = 34; //[24:50:0.5]
filter_can_height = 26; //[18:40:0.5]
filter_can_depth = 18; //[10:35:0.5]
panel_profile_thickness = 3; //[1:10:0.5]
overlap = 1; //[0.5:2:0.1]

// IEC Module
module iec() {
  color("Black") {
    // Front Flange Bezel
    difference() {
      translate([0, 0, (flange_thickness + bezel_thickness) / 2])
        cube([overall_width, overall_height, flange_thickness + bezel_thickness], center=true);
      translate([0, 0, (flange_thickness + bezel_thickness) / 2 - (orifice_depth + flange_thickness + bezel_thickness + overlap) / 2 + overlap])
        cube([orifice_width + 2 * cutout_clearance, orifice_height + 2 * cutout_clearance, orifice_depth + flange_thickness + bezel_thickness + overlap], center=true);
      translate([-screw_hole_pitch_x / 2, -screw_hole_pitch_y / 2, (flange_thickness + bezel_thickness) / 2])
        cylinder(r=screw_hole_diameter / 2, h=flange_thickness + bezel_thickness + overlap * 2, center=true);
      translate([screw_hole_pitch_x / 2, screw_hole_pitch_y / 2, (flange_thickness + bezel_thickness) / 2])
        cylinder(r=screw_hole_diameter / 2, h=flange_thickness + bezel_thickness + overlap * 2, center=true);
    }
    
    // IEC Filtered Inlet Body
    difference() {
      translate([0, 0, -body_depth / 2 + overlap])
        cube([body_width, body_height, body_depth], center=true);
      translate([0, 0, (flange_thickness + bezel_thickness) / 2 - (orifice_depth + flange_thickness + bezel_thickness + overlap) / 2 + overlap])
        cube([orifice_width + 2 * cutout_clearance, orifice_height + 2 * cutout_clearance, orifice_depth + flange_thickness + bezel_thickness + overlap], center=true);
    }
    
    // Rear Can Filter Housing
    if (filter_can_enabled) {
      translate([0, 0, -body_depth + (filter_can_depth * filter_can_enabled) / 2 + overlap])
        cube([filter_can_width, filter_can_height, filter_can_depth * filter_can_enabled], center=true);
    }
    
    // Terminal Spades
    translate([0, terminal_spade_pitch_y, -body_depth - terminal_spade_length / 2 + overlap])
      cube([terminal_spade_thickness, terminal_spade_width, terminal_spade_length], center=true);
    translate([-terminal_spade_pitch_x / 2, -terminal_spade_pitch_y, -body_depth - terminal_spade_length / 2 + overlap])
      cube([terminal_spade_thickness, terminal_spade_width, terminal_spade_length], center=true);
    translate([terminal_spade_pitch_x / 2, -terminal_spade_pitch_y, -body_depth - terminal_spade_length / 2 + overlap])
      cube([terminal_spade_thickness, terminal_spade_width, terminal_spade_length], center=true);
  }
}

// Mod Module
module mod() {
  color("Silver") {
    // Panel Cutout Profile
    difference() {
      translate([0, 0, panel_profile_thickness / 2])
        cube([body_width + 2 * cutout_clearance, body_height + 2 * cutout_clearance, panel_profile_thickness], center=true);
      translate([0, 0, (flange_thickness + bezel_thickness) / 2 - (orifice_depth + flange_thickness + bezel_thickness + overlap) / 2 + overlap])
        cube([orifice_width + 2 * cutout_clearance, orifice_height + 2 * cutout_clearance, orifice_depth + flange_thickness + bezel_thickness + overlap], center=true);
      translate([-screw_hole_pitch_x / 2, -screw_hole_pitch_y / 2, (flange_thickness + bezel_thickness) / 2])
        cylinder(r=screw_hole_diameter / 2, h=flange_thickness + bezel_thickness + overlap * 2, center=true);
      translate([screw_hole_pitch_x / 2, screw_hole_pitch_y / 2, (flange_thickness + bezel_thickness) / 2])
        cylinder(r=screw_hole_diameter / 2, h=flange_thickness + bezel_thickness + overlap * 2, center=true);
    }
  }
}

// Assembly
module assembly() {
  iec();
  mod();
}

assembly();