// Parameters
screw_thread_diameter_mm = 4.0; //[2.0:8.0:0.1]
thread_pitch_mm = 0.7; //[0.35:1.4:0.05]
across_flats_mm = 6.0; //[3.0:12.0:0.1]
thickness_mm = 3.7; //[1.85:7.4:0.1]
overall_length_mm = 12.0; //[6.0:24.0:0.5]
overall_width_mm = 10.0; //[5.0:20.0:0.5]
slot_internal_width_mm = 8.2; //[6.0:12.0:0.1]
slot_width_mm = 6.2; //[4.0:10.0:0.1]
slot_lip_thickness_mm = 1.8; //[0.9:3.6:0.1]
slot_depth_mm = 6.0; //[3.0:12.0:0.5]
edge_chamfer_mm = 0.3; //[0.15:0.6:0.05]
corner_radius_mm = 0.2; //[0.1:0.6:0.05]
thread_hole_diameter_mm = 3.3; //[2.5:4.2:0.05]
hole_clearance_diameter_mm = 4.3; //[4.0:5.0:0.05]
wing_overlap_mm = 0.8; //[0.4:1.6:0.1]
anti_rotation_rib_depth_mm = 0.6; //[0.3:1.2:0.05]
anti_rotation_rib_width_mm = 1.2; //[0.6:2.4:0.1]
anti_rotation_rib_length_mm = 8.0; //[4.0:16.0:0.5]
include_nut_and_washer = 1; //[0:1:1]
ref_washer_od_mm = 9.0; //[6.0:18.0:0.5]
ref_washer_thickness_mm = 1.0; //[0.5:2.0:0.1]
ref_nut_thickness_mm = 3.2; //[1.6:6.4:0.1]
ref_nut_across_flats_mm = 7.0; //[3.5:14.0:0.1]
ref_stack_overlap_mm = 0.8; //[0.4:1.6:0.1]

// Nut and Washer - complete geometry
module nut_and_washer() {
  color("Silver") {
    // Washer
    translate([0, 0, thickness_mm/2 + ref_washer_thickness_mm/2 - ref_stack_overlap_mm])
      cylinder(r=ref_washer_od_mm/2, h=ref_washer_thickness_mm, center=true, $fn=32);
    // Nut
    translate([0, 0, thickness_mm/2 + ref_washer_thickness_mm + ref_nut_thickness_mm/2 - ref_stack_overlap_mm])
      cylinder(r=(ref_nut_across_flats_mm/2)/cos(30), h=ref_nut_thickness_mm, center=true, $fn=6);
  }
}

// T-slot nut body with wings and ribs
module t_slot_nut() {
  color("DimGray") {
    // Main body
    difference() {
      union() {
        // Nut body
        translate([0, 0, 0])
          cube([overall_length_mm, across_flats_mm, thickness_mm], center=true);
        // Wings
        translate([0, -(slot_internal_width_mm/2 + ((overall_width_mm - slot_internal_width_mm)/2 + wing_overlap_mm)/2 - wing_overlap_mm/2), -(thickness_mm/2 - min(thickness_mm, slot_lip_thickness_mm)/2)])
          cube([overall_length_mm, (overall_width_mm - slot_internal_width_mm)/2 + wing_overlap_mm, min(thickness_mm, slot_lip_thickness_mm)], center=true);
        translate([0, (slot_internal_width_mm/2 + ((overall_width_mm - slot_internal_width_mm)/2 + wing_overlap_mm)/2 - wing_overlap_mm/2), -(thickness_mm/2 - min(thickness_mm, slot_lip_thickness_mm)/2)])
          cube([overall_length_mm, (overall_width_mm - slot_internal_width_mm)/2 + wing_overlap_mm, min(thickness_mm, slot_lip_thickness_mm)], center=true);
        // Anti-rotation ribs
        translate([0, -(across_flats_mm/4), (thickness_mm/2 + anti_rotation_rib_depth_mm/2 - 0.5)])
          cube([anti_rotation_rib_length_mm, anti_rotation_rib_width_mm, anti_rotation_rib_depth_mm], center=true);
        translate([0, (across_flats_mm/4), (thickness_mm/2 + anti_rotation_rib_depth_mm/2 - 0.5)])
          cube([anti_rotation_rib_length_mm, anti_rotation_rib_width_mm, anti_rotation_rib_depth_mm], center=true);
      }
      // Lead-in chamfers
      translate([(overall_length_mm/2 - edge_chamfer_mm), 0, 0])
        rotate([0, 45, 0])
        cube([edge_chamfer_mm*2, overall_width_mm*1.2, thickness_mm*1.2], center=true);
      translate([-(overall_length_mm/2 - edge_chamfer_mm), 0, 0])
        rotate([0, -45, 0])
        cube([edge_chamfer_mm*2, overall_width_mm*1.2, thickness_mm*1.2], center=true);
    }
    // Hex profile
    intersection() {
      cube([overall_length_mm, across_flats_mm, thickness_mm], center=true);
      cylinder(r=(across_flats_mm/2)/cos(30), h=thickness_mm, center=true, $fn=6);
    }
    // Threaded hole
    translate([0, 0, 0])
      cylinder(r=thread_hole_diameter_mm/2, h=thickness_mm*2, center=true, $fn=32);
  }
}

// Assembly
module assembly() {
  t_slot_nut();
  if (include_nut_and_washer) {
    nut_and_washer();
  }
}

assembly();