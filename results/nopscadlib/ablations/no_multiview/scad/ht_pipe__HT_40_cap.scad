// Parameters
nominal_diameter_mm = 40; //[20:80:1]
pipe_od_mm = 40; //[20:80:0.1]
cap_outer_diameter_mm = 50; //[25:100:0.1]
cap_total_height_mm = 35; //[18:70:0.1]
socket_depth_mm = 25; //[10:60:0.1]
cap_wall_thickness_mm = 3; //[1.5:6:0.1]
end_face_thickness_mm = 3; //[1.5:8:0.1]
clearance_mm = 0.3; //[0.1:1:0.05]
overlap_mm = 1; //[0.5:2:0.1]
pipe_wall_mm = 2.2; //[1.1:4.4:0.1]
pipe_length_mm = 60; //[30:120:1]

// PVC HT Pipe End Cap
module cap_body() {
  difference() {
    // Outer cap body
    cylinder(r=cap_outer_diameter_mm/2, h=cap_total_height_mm, center=true);
    // Inner stop shoulder void
    translate([0, 0, -end_face_thickness_mm/2 - overlap_mm/2])
      cylinder(r=cap_outer_diameter_mm/2 - cap_wall_thickness_mm, h=cap_total_height_mm - end_face_thickness_mm + overlap_mm, center=true);
    // Internal socket void
    translate([0, 0, cap_total_height_mm/2 - end_face_thickness_mm - socket_depth_mm/2])
      cylinder(r=pipe_od_mm/2 + clearance_mm, h=socket_depth_mm + overlap_mm, center=true);
  }
}

// HT Pipe
module ht_pipe() {
  difference() {
    // Outer pipe
    translate([0, 0, cap_total_height_mm/2 - end_face_thickness_mm - pipe_length_mm/2 + overlap_mm])
      cylinder(r=pipe_od_mm/2, h=pipe_length_mm, center=true);
    // Inner pipe void
    translate([0, 0, cap_total_height_mm/2 - end_face_thickness_mm - pipe_length_mm/2 + overlap_mm])
      cylinder(r=pipe_od_mm/2 - pipe_wall_mm, h=pipe_length_mm + overlap_mm, center=true);
  }
}

// Assembly
module assembly() {
  color([0.85, 0.85, 0.8]) cap_body();
  color([0.2, 0.2, 0.2]) ht_pipe();
}

assembly();