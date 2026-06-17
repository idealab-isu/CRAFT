// Parameters
screw_thread_diameter_mm = 5.0; //[2.5:10.0:0.1]
screw_thread_pitch_mm = 0.8; //[0.4:1.6:0.05]
across_flats_mm = 6.0; //[3.0:12.0:0.1]
thickness_mm = 3.7; //[1.8:7.4:0.1]
threaded_hole_tap_drill_diameter_mm = 4.2; //[3.0:6.0:0.05]
thread_clearance_allowance_mm = 0.15; //[0.0:0.5:0.01]
t_slot_nominal_width_mm = 8.0; //[4.0:16.0:0.1]
t_slot_neck_width_mm = 6.0; //[3.0:12.0:0.1]
t_slot_depth_mm = 6.0; //[3.0:12.0:0.1]
overall_length_mm = 12.0; //[6.0:24.0:0.1]
overall_width_mm = 7.8; //[4.0:16.0:0.1]
shoulder_height_mm = 0.8; //[0.3:2.0:0.05]
shoulder_width_mm = 0.9; //[0.3:2.5:0.05]
chamfer_mm = 0.3; //[0.0:1.0:0.05]
fillet_radius_mm = 0.2; //[0.0:1.0:0.05]
overlap_mm = 0.8; //[0.2:2.0:0.1]
washer_outer_diameter_mm = 10.0; //[6.0:20.0:0.1]
washer_thickness_mm = 1.0; //[0.5:2.5:0.1]
assembly_gap_mm = 0.6; //[0.0:3.0:0.1]

// Nut and Washer - complete geometry
module nut_and_washer() {
  color("DimGray") {
    // Hex outer profile
    cylinder(r=across_flats_mm/(2*cos(30)), h=thickness_mm, center=true);

    // T-slot nut body block
    translate([0, 0, 0])
      cube([overall_length_mm, t_slot_neck_width_mm, thickness_mm], center=true);

    // T-slot retention shoulders
    translate([0, 0, 0])
      cube([overall_length_mm, t_slot_neck_width_mm + 2*shoulder_width_mm, 2*shoulder_height_mm], center=true);

    // Threaded through hole
    translate([0, 0, 0])
      cylinder(r=(threaded_hole_tap_drill_diameter_mm + thread_clearance_allowance_mm)/2, h=thickness_mm + 2*overlap_mm, center=true);

    // Lead-in chamfer wedges
    translate([overall_length_mm/2 - chamfer_mm/2 + overlap_mm/2, 0, 0])
      cube([chamfer_mm, overall_width_mm + 2*overlap_mm, thickness_mm + 2*overlap_mm], center=true);
    translate([-overall_length_mm/2 + chamfer_mm/2 - overlap_mm/2, 0, 0])
      cube([chamfer_mm, overall_width_mm + 2*overlap_mm, thickness_mm + 2*overlap_mm], center=true);

    // Edge chamfer wedges
    translate([0, overall_width_mm/2 - fillet_radius_mm/2 + overlap_mm/2, 0])
      cube([overall_length_mm + 2*overlap_mm, fillet_radius_mm, thickness_mm + 2*overlap_mm], center=true);
    translate([0, -overall_width_mm/2 + fillet_radius_mm/2 - overlap_mm/2, 0])
      cube([overall_length_mm + 2*overlap_mm, fillet_radius_mm, thickness_mm + 2*overlap_mm], center=true);
  }

  // Washer
  color("Silver") {
    translate([0, 0, thickness_mm/2 + washer_thickness_mm/2 - overlap_mm])
      difference() {
        cylinder(r=washer_outer_diameter_mm/2, h=washer_thickness_mm, center=true);
        cylinder(r=(screw_thread_diameter_mm + thread_clearance_allowance_mm)/2, h=washer_thickness_mm + 2*overlap_mm, center=true);
      }
  }
}

// Assembly
module assembly() {
  nut_and_washer();
}

assembly();