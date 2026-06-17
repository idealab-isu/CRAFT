// Parameters
nominal_size = 32; //[16:64:1]
pipe_od_mm = 32; //[16:64:0.1]
cap_outer_diameter_mm = 40; //[20:80:0.1]
socket_inner_diameter_mm = 32.4; //[16.2:64.8:0.1]
socket_depth_mm = 30; //[15:60:0.1]
wall_thickness_mm = 3; //[1.5:6:0.1]
end_wall_thickness_mm = 4; //[2:8:0.1]
lead_in_chamfer_mm = 1; //[0.5:3:0.1]
outer_fillet_radius_mm = 1; //[0.5:3:0.1]
pipe_wall_mm = 2.4; //[1.2:4.8:0.1]
pipe_stub_length_mm = 60; //[30:120:1]
overlap_mm = 1; //[0.5:2:0.1]
eps_mm = 0.2; //[0.05:0.5:0.05]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    difference() {
      // Outer pipe
      cylinder(r=pipe_od_mm/2, h=pipe_stub_length_mm, center=true);
      // Inner pipe
      translate([0, 0, -eps_mm/2])
        cylinder(r=pipe_od_mm/2 - pipe_wall_mm, h=pipe_stub_length_mm + eps_mm, center=true);
    }
  }
}

// Cap with socket and end wall
module cap() {
  color([0.2, 0.2, 0.2]) {
    difference() {
      // Outer shell
      cylinder(r=cap_outer_diameter_mm/2, h=socket_depth_mm + end_wall_thickness_mm, center=true);
      // Internal socket
      translate([0, 0, (socket_depth_mm + end_wall_thickness_mm)/2 - socket_depth_mm/2])
        cylinder(r=socket_inner_diameter_mm/2, h=socket_depth_mm + eps_mm, center=true);
      // Lead-in chamfer
      translate([0, 0, (socket_depth_mm + end_wall_thickness_mm)/2 - (lead_in_chamfer_mm/2)])
        cylinder(r1=socket_inner_diameter_mm/2 + lead_in_chamfer_mm, r2=socket_inner_diameter_mm/2, h=lead_in_chamfer_mm + eps_mm, center=true);
    }
    // End wall
    translate([0, 0, -(socket_depth_mm + end_wall_thickness_mm)/2 + end_wall_thickness_mm/2])
      cylinder(r=cap_outer_diameter_mm/2, h=end_wall_thickness_mm, center=true);
  }
}

// Assembly
module assembly() {
  union() {
    // Cap with rounded edges
    minkowski() {
      cap();
      sphere(r=outer_fillet_radius_mm, center=true);
    }
    // HT Pipe
    translate([0, 0, (socket_depth_mm + end_wall_thickness_mm)/2 + pipe_stub_length_mm/2 - overlap_mm])
      ht_pipe();
  }
}

assembly();