// Parameters
nominal_diameter_mm = 110; //[55:220:1]
pipe_outer_diameter_mm = 110; //[55:220:0.5]
socket_inner_diameter_mm = 110.5; //[55:221:0.1]
cap_wall_thickness_mm = 3.2; //[1.6:6.4:0.1]
end_face_thickness_mm = 4; //[2:8:0.1]
insertion_depth_mm = 50; //[25:100:1]
overall_height_mm = 60; //[30:120:1]
fillet_radius_mm = 1; //[0.5:3:0.1]
draft_angle_deg = 1; //[0:5:0.1]
tolerance_clearance_mm = 0.5; //[0.2:1.5:0.1]
overlap_mm = 1; //[0.5:2:0.1]
cap_outer_diameter_mm = 116.9; //[58.45:233.8:0.1]
stop_shoulder_thickness_mm = 3; //[1.5:6:0.1]
stop_shoulder_radial_mm = 2; //[1:5:0.1]
grip_band_height_mm = 15; //[7.5:30:0.5]
grip_band_radial_mm = 1.5; //[0.5:4:0.1]
pipe_wall_thickness_mm = 3.2; //[1.6:6.4:0.1]
pipe_length_mm = 120; //[60:240:1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    difference() {
      // Outer pipe
      cylinder(r=pipe_outer_diameter_mm/2, h=pipe_length_mm, center=true);
      // Inner bore
      translate([0, 0, -overlap_mm/2])
        cylinder(r=pipe_outer_diameter_mm/2 - pipe_wall_thickness_mm, h=pipe_length_mm + overlap_mm, center=true);
    }
  }
}

// Cap assembly
module cap() {
  color([0.75, 0.75, 0.77]) {
    difference() {
      // Cap body with closed end
      union() {
        // Outer cap body
        cylinder(r=cap_outer_diameter_mm/2, h=overall_height_mm, center=true);
        // Closed end face
        translate([0, 0, overall_height_mm/2 - end_face_thickness_mm/2])
          cylinder(r=cap_outer_diameter_mm/2, h=end_face_thickness_mm, center=true);
        // Outer grip band
        translate([0, 0, -overall_height_mm/2 + grip_band_height_mm/2])
          cylinder(r=cap_outer_diameter_mm/2 + grip_band_radial_mm, h=grip_band_height_mm, center=true);
      }
      // Internal clearance bore
      translate([0, 0, -overall_height_mm/2 + (insertion_depth_mm + overlap_mm)/2])
        cylinder(r=socket_inner_diameter_mm/2, h=insertion_depth_mm + overlap_mm, center=true);
    }
    // Insertion stop shoulder
    union() {
      // Stop shoulder
      translate([0, 0, -overall_height_mm/2 + insertion_depth_mm - stop_shoulder_thickness_mm/2])
        cylinder(r=socket_inner_diameter_mm/2, h=stop_shoulder_thickness_mm, center=true);
      // Stop shoulder bore
      translate([0, 0, -overall_height_mm/2 + insertion_depth_mm - stop_shoulder_thickness_mm/2])
        difference() {
          cylinder(r=socket_inner_diameter_mm/2, h=stop_shoulder_thickness_mm, center=true);
          cylinder(r=socket_inner_diameter_mm/2 - stop_shoulder_radial_mm, h=stop_shoulder_thickness_mm + overlap_mm, center=true);
        }
    }
  }
}

// Assembly
module assembly() {
  cap();
  translate([0, 0, -overall_height_mm/2 - pipe_length_mm/2 + overlap_mm]) ht_pipe();
}

assembly();