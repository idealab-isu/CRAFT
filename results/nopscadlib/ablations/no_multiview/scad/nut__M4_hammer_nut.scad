// Parameters
screw_diameter_mm = 4.0; //[2.0:8.0:0.1]
thread_pitch_mm = 0.7; //[0.35:1.4:0.05]
across_flats_mm = 6.0; //[3.0:12.0:0.1]
thickness_mm = 3.25; //[1.6:6.5:0.05]
pilot_hole_diameter_mm = 3.3; //[2.5:4.2:0.05]
clearance_mm = 0.15; //[0.05:0.4:0.01]
corner_chamfer_mm = 0.3; //[0.1:1.0:0.05]
edge_fillet_radius_mm = 0.2; //[0.0:1.0:0.05]
t_slot_opening_width_mm = 6.2; //[4.0:12.0:0.1]
t_slot_internal_width_mm = 10.0; //[6.0:20.0:0.1]
t_slot_depth_mm = 6.0; //[3.0:12.0:0.1]
nut_overall_length_mm = 12.0; //[6.0:24.0:0.1]
nut_overall_width_mm = 9.6; //[5.0:18.0:0.1]
lip_height_mm = 1.0; //[0.5:2.5:0.05]
lip_width_mm = 1.2; //[0.6:3.0:0.05]
overlap_mm = 0.8; //[0.5:2.0:0.1]
anti_rotation_bump_depth_mm = 0.4; //[0.2:1.2:0.05]
anti_rotation_bump_length_mm = 4.0; //[2.0:10.0:0.1]

// Nut and Washer - complete geometry
module nut_and_washer() {
  color("DimGray") {
    // Hex profile
    cylinder(r=across_flats_mm/(2*cos(30)), h=thickness_mm, center=true);
    
    // T-slot nut body
    translate([0, 0, 0])
      cube([nut_overall_length_mm, nut_overall_width_mm, thickness_mm], center=true);
    
    // T-slot engagement lips
    translate([0, 0, -thickness_mm/2 + lip_height_mm])
      cube([nut_overall_length_mm, nut_overall_width_mm + 2*lip_width_mm, 2*lip_height_mm], center=true);
    
    // Anti-rotation features
    translate([0, -(nut_overall_width_mm/2 + anti_rotation_bump_depth_mm/2 - overlap_mm), 0])
      cube([anti_rotation_bump_length_mm, anti_rotation_bump_depth_mm, thickness_mm], center=true);
    translate([0, (nut_overall_width_mm/2 + anti_rotation_bump_depth_mm/2 - overlap_mm), 0])
      cube([anti_rotation_bump_length_mm, anti_rotation_bump_depth_mm, thickness_mm], center=true);
    
    // Lead-in chamfers
    hull() {
      translate([nut_overall_length_mm/2 - corner_chamfer_mm/2, 0, 0])
        cube([corner_chamfer_mm, nut_overall_width_mm + 2*lip_width_mm, thickness_mm], center=true);
      translate([nut_overall_length_mm/2 - (corner_chamfer_mm + overlap_mm)/2 - overlap_mm, 0, 0])
        cube([corner_chamfer_mm + overlap_mm, nut_overall_width_mm + 2*lip_width_mm + 2*corner_chamfer_mm, thickness_mm], center=true);
    }
    hull() {
      translate([-(nut_overall_length_mm/2 - corner_chamfer_mm/2), 0, 0])
        cube([corner_chamfer_mm, nut_overall_width_mm + 2*lip_width_mm, thickness_mm], center=true);
      translate([-(nut_overall_length_mm/2 - (corner_chamfer_mm + overlap_mm)/2 - overlap_mm), 0, 0])
        cube([corner_chamfer_mm + overlap_mm, nut_overall_width_mm + 2*lip_width_mm + 2*corner_chamfer_mm, thickness_mm], center=true);
    }
  }
}

// Assembly
module assembly() {
  difference() {
    nut_and_washer();
    // Central threaded hole
    translate([0, 0, 0])
      cylinder(r=pilot_hole_diameter_mm/2, h=thickness_mm + 2*overlap_mm, center=true);
  }
}

assembly();