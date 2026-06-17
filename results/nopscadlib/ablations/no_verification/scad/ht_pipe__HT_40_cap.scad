// Parameters
pipe_outer_diameter_mm = 40; //[20:80:0.1]
cap_outer_diameter_mm = 48; //[24:96:0.1]
cap_total_height_mm = 35; //[18:70:0.1]
socket_insertion_depth_mm = 25; //[12:50:0.1]
cap_wall_thickness_mm = 3; //[1.5:6:0.1]
end_face_thickness_mm = 4; //[2:8:0.1]
clearance_mm = 0.3; //[0.1:1:0.05]
fillet_radius_mm = 1; //[0.5:3:0.1]
grip_rim_radial_mm = 2; //[1:5:0.1]
grip_rim_height_mm = 6; //[3:12:0.1]
stop_shoulder_height_mm = 2; //[1:5:0.1]
overlap_mm = 1; //[0.5:2:0.1]
pipe_visual_length_mm = 60; //[30:120:1]
pipe_wall_thickness_mm = 3; //[1.5:6:0.1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    difference() {
      // Outer pipe
      cylinder(r=pipe_outer_diameter_mm/2, h=pipe_visual_length_mm, center=true);
      // Inner cavity
      translate([0, 0, -overlap_mm/2])
        cylinder(r=pipe_outer_diameter_mm/2 - pipe_wall_thickness_mm, h=pipe_visual_length_mm + overlap_mm, center=true);
    }
  }
}

// Cap - complete geometry
module cap() {
  color([0.2, 0.2, 0.2]) {
    difference() {
      // Cap body with grip rim
      union() {
        // Outer cap body
        cylinder(r=cap_outer_diameter_mm/2, h=cap_total_height_mm, center=true);
        // Grip rim
        translate([0, 0, -cap_total_height_mm/2 + grip_rim_height_mm/2 - overlap_mm])
          cylinder(r=cap_outer_diameter_mm/2 + grip_rim_radial_mm, h=grip_rim_height_mm, center=true);
      }
      // Fillet (rounded edges)
      minkowski() {
        sphere(r=fillet_radius_mm, center=true);
        union() {
          // Outer cap body
          cylinder(r=cap_outer_diameter_mm/2, h=cap_total_height_mm, center=true);
          // Grip rim
          translate([0, 0, -cap_total_height_mm/2 + grip_rim_height_mm/2 - overlap_mm])
            cylinder(r=cap_outer_diameter_mm/2 + grip_rim_radial_mm, h=grip_rim_height_mm, center=true);
        }
      }
      // End face trim
      translate([0, 0, -cap_total_height_mm/2 + (cap_total_height_mm - end_face_thickness_mm)/2 - overlap_mm])
        cylinder(r=cap_outer_diameter_mm/2 + grip_rim_radial_mm + fillet_radius_mm, h=cap_total_height_mm - end_face_thickness_mm, center=true);
      // Inner socket cavity
      translate([0, 0, -cap_total_height_mm/2 + (socket_insertion_depth_mm + overlap_mm)/2])
        cylinder(r=pipe_outer_diameter_mm/2 + clearance_mm, h=socket_insertion_depth_mm + overlap_mm, center=true);
    }
    // Socket stop shoulder
    translate([0, 0, -cap_total_height_mm/2 + socket_insertion_depth_mm - stop_shoulder_height_mm/2])
      cylinder(r=pipe_outer_diameter_mm/2 + clearance_mm + cap_wall_thickness_mm, h=stop_shoulder_height_mm, center=true);
  }
}

// Assembly
module assembly() {
  cap();
  translate([0, 0, -cap_total_height_mm/2 - pipe_visual_length_mm/2 + overlap_mm])
    ht_pipe();
}

assembly();