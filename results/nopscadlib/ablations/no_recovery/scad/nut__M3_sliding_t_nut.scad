// Parameters
screw_diameter = 3.0; //[1.5:6.0:0.1]
thread_pitch = 0.5; //[0.25:1.0:0.05]
across_flats = 6.0; //[3.0:12.0:0.1]
thickness = 3.0; //[1.5:6.0:0.1]
body_length = 10.0; //[5.0:20.0:0.5]
body_width = 6.2; //[3.5:12.0:0.1]
tolerance_general = 0.1; //[0.05:0.3:0.01]
corner_chamfer = 0.3; //[0.0:1.0:0.05]
edge_fillet_radius = 0.2; //[0.0:1.0:0.05]
thread_tap_drill_diameter = 2.5; //[1.5:4.0:0.1]
clearance_hole_diameter = 3.2; //[3.0:4.5:0.1]
hole_style_selector = 0; //[0:2:1]
hole_diameter_threaded = 3.0; //[2.5:3.5:0.05]
hole_diameter = 3.0; //[2.0:4.5:0.05]
hole_extra_height = 2.0; //[1.0:6.0:0.5]
overlap = 1.0; //[0.5:2.0:0.1]
anti_rotation_nib_height = 0.6; //[0.3:1.5:0.1]
anti_rotation_nib_length = 4.0; //[2.0:8.0:0.5]
anti_rotation_nib_thickness = 2.0; //[1.0:3.0:0.1]
t_slot_nominal_width = 6.0; //[4.0:10.0:0.1]
slot_entry_width = 3.2; //[2.0:6.0:0.1]
slot_undercut_width = 6.2; //[4.0:10.0:0.1]
slot_depth = 6.0; //[3.0:12.0:0.1]
t_slot_profile_length = 12.0; //[6.0:30.0:1]
t_slot_profile_wall = 2.0; //[1.0:5.0:0.1]
include_reference_nut_and_washer = 1; //[0:1:1]
ref_nut_thickness = 2.4; //[1.2:5.0:0.1]
ref_washer_thickness = 0.8; //[0.4:2.0:0.1]
ref_washer_od = 7.0; //[5.0:14.0:0.1]
ref_washer_id = 3.2; //[3.0:5.0:0.1]

// Nut and Washer - complete geometry
module nut_and_washer() {
  color("Silver") {
    // Washer
    difference() {
      cylinder(r=ref_washer_od/2, h=ref_washer_thickness, center=true);
      translate([0, 0, 0])
        cylinder(r=ref_washer_id/2, h=ref_washer_thickness + overlap*2, center=true);
    }
    // Nut
    translate([0, 0, ref_washer_thickness]) {
      difference() {
        cylinder(r=across_flats/(2*cos(30)), h=ref_nut_thickness, center=true);
        translate([0, 0, 0])
          cylinder(r=(clearance_hole_diameter/2) + tolerance_general/2, h=ref_nut_thickness + overlap*2, center=true);
      }
    }
  }
}

// T-slot nut body
module t_slot_nut_body() {
  color("DimGray") {
    difference() {
      union() {
        // Hex body
        cylinder(r=across_flats/(2*cos(30)), h=thickness, center=true);
        // Length box
        cube([body_length, body_width, thickness], center=true);
        // Anti-rotation nibs
        translate([0, body_width/2 + anti_rotation_nib_height/2 - overlap, 0])
          cube([anti_rotation_nib_length, anti_rotation_nib_height, min(anti_rotation_nib_thickness, thickness)], center=true);
        translate([0, -(body_width/2 + anti_rotation_nib_height/2 - overlap), 0])
          cube([anti_rotation_nib_length, anti_rotation_nib_height, min(anti_rotation_nib_thickness, thickness)], center=true);
      }
      // Lead-in chamfers
      translate([body_length/2 - corner_chamfer, 0, 0])
        rotate([0, 0, 45])
        cube([corner_chamfer*2, body_width + anti_rotation_nib_height*2, thickness + overlap*2], center=true);
      translate([-(body_length/2 - corner_chamfer), 0, 0])
        rotate([0, 0, 45])
        cube([corner_chamfer*2, body_width + anti_rotation_nib_height*2, thickness + overlap*2], center=true);
      // Threaded hole
      translate([0, 0, 0])
        cylinder(r=(hole_diameter/2) + tolerance_general/2, h=thickness + hole_extra_height, center=true);
    }
  }
}

// T-slot profile
module t_slot_profile() {
  color("Black") {
    difference() {
      // Outer profile
      cube([t_slot_profile_length, slot_undercut_width + 2*t_slot_profile_wall, slot_depth + 2*t_slot_profile_wall], center=true);
      // Inner void
      translate([0, 0, 0])
        cube([t_slot_profile_length + overlap*2, slot_undercut_width, slot_depth], center=true);
      // Entry void
      translate([0, 0, 0])
        cube([t_slot_profile_length + overlap*2, slot_entry_width, slot_depth + 2*t_slot_profile_wall + overlap*2], center=true);
    }
  }
}

// Assembly
module assembly() {
  t_slot_nut_body();
  translate([0, 0, -(thickness/2 + (slot_depth + 2*t_slot_profile_wall)/2 - overlap)])
    t_slot_profile();
  if (include_reference_nut_and_washer) {
    translate([0, 0, thickness/2 + ref_washer_thickness/2 - overlap])
      nut_and_washer();
  }
}

assembly();