// Parameters
nominal_diameter_mm = 110; //[55:220:1]
pipe_outer_diameter_mm = 110; //[90:140:0.1]
cap_outer_diameter_mm = 125; //[110:160:0.1]
wall_thickness_mm = 3.2; //[1.6:6.4:0.1]
socket_inner_diameter_mm = 110.5; //[109:113:0.1]
socket_depth_mm = 50; //[30:90:1]
end_face_thickness_mm = 4; //[2:10:0.5]
stop_shoulder_height_mm = 2; //[1:6:0.5]
outer_rim_height_mm = 8; //[4:20:1]
outer_rim_thickness_mm = 2; //[1:6:0.5]
fillet_radius_mm = 1; //[0:3:0.25]
overlap_mm = 1; //[0.5:2:0.1]
pipe_wall_thickness_mm = 3.2; //[1.6:6.4:0.1]
pipe_stub_length_mm = 80; //[40:160:1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    difference() {
      // Outer pipe
      cylinder(r=pipe_outer_diameter_mm/2, h=pipe_stub_length_mm, center=true);
      // Inner pipe
      translate([0, 0, -overlap_mm/2])
        cylinder(r=pipe_outer_diameter_mm/2 - pipe_wall_thickness_mm, h=pipe_stub_length_mm + overlap_mm, center=true);
    }
  }
}

// Cap assembly
module cap() {
  color([0.85, 0.85, 0.8]) {
    difference() {
      union() {
        // Cap body
        translate([0, 0, 0])
          cylinder(r=cap_outer_diameter_mm/2, h=socket_depth_mm + end_face_thickness_mm, center=true);
        // Closed end face
        translate([0, 0, (socket_depth_mm + end_face_thickness_mm)/2 - end_face_thickness_mm/2])
          cylinder(r=cap_outer_diameter_mm/2, h=end_face_thickness_mm, center=true);
        // Outer grip rim
        translate([0, 0, -(socket_depth_mm + end_face_thickness_mm)/2 + outer_rim_height_mm/2])
          cylinder(r=cap_outer_diameter_mm/2 + outer_rim_thickness_mm, h=outer_rim_height_mm, center=true);
        // Insertion stop shoulder
        translate([0, 0, -(socket_depth_mm + end_face_thickness_mm)/2 + socket_depth_mm - stop_shoulder_height_mm/2])
          cylinder(r=(socket_inner_diameter_mm/2) - wall_thickness_mm, h=stop_shoulder_height_mm, center=true);
      }
      // Inner socket cavity
      translate([0, 0, -(socket_depth_mm + end_face_thickness_mm)/2 + (socket_depth_mm + overlap_mm)/2])
        cylinder(r=socket_inner_diameter_mm/2, h=socket_depth_mm + overlap_mm, center=true);
    }
  }
}

// Assembly
module assembly() {
  cap();
  translate([0, 0, -(socket_depth_mm + end_face_thickness_mm)/2 + socket_depth_mm/2 - overlap_mm])
    ht_pipe();
}

assembly();