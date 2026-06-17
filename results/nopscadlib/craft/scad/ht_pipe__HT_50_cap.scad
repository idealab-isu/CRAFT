// Parameters
nominal_diameter_mm = 50; //[25:100:1]
tolerance_mm = 0.2; //[0.0:1.0:0.05]
wall_thickness_mm = 3.0; //[1.5:6.0:0.1]
cap_outer_diameter_mm = 56.0; //[45.0:80.0:0.5]
cap_length_mm = 35.0; //[20.0:70.0:0.5]
socket_depth_mm = 25.0; //[10.0:60.0:0.5]
pipe_outer_diameter_mm = 50.0; //[25.0:100.0:1]
pipe_wall_mm = 1.8; //[1.0:4.0:0.1]
pipe_stub_length_mm = 60.0; //[20.0:150.0:1]
include_pipe_stub = 0; //[0:1:1]
overlap_mm = 1.0; //[0.5:2.0:0.1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // Off-white for PVC
    difference() {
      // Outer pipe
      cylinder(h=pipe_stub_length_mm, r=pipe_outer_diameter_mm/2, center=true);
      // Inner void
      translate([0, 0, -overlap_mm/2])
        cylinder(h=pipe_stub_length_mm + overlap_mm, r=(pipe_outer_diameter_mm/2) - pipe_wall_mm, center=true);
    }
  }
}

// Cap body - complete geometry
module cap_body() {
  color([0.85, 0.85, 0.8]) { // Off-white for PVC
    difference() {
      // Outer cap
      cylinder(h=cap_length_mm, r=cap_outer_diameter_mm/2, center=true);
      // Socket void
      translate([0, 0, -cap_length_mm/2 + (socket_depth_mm + overlap_mm)/2])
        cylinder(h=socket_depth_mm + overlap_mm, r=(pipe_outer_diameter_mm + 2*tolerance_mm)/2, center=true);
      // End face void
      translate([0, 0, (-cap_length_mm/2 + wall_thickness_mm) + (cap_length_mm - wall_thickness_mm)/2])
        cylinder(h=cap_length_mm - wall_thickness_mm, r=(cap_outer_diameter_mm/2) - wall_thickness_mm, center=true);
    }
  }
}

// Assembly
module assembly() {
  cap_body();
  if (include_pipe_stub) {
    translate([0, 0, -cap_length_mm/2 + pipe_stub_length_mm/2 - overlap_mm])
      ht_pipe();
  }
}

assembly();