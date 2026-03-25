// Parameters
pipe_outer_diameter_mm = 32; //[16:64:0.1]
cap_outer_diameter_mm = 40; //[20:80:0.1]
socket_inner_diameter_mm = 32.4; //[16.2:64.8:0.1]
socket_depth_mm = 30; //[15:60:0.1]
wall_thickness_mm = 2.5; //[1.25:5:0.1]
end_thickness_mm = 3; //[1.5:6:0.1]
internal_stop_offset_mm = 28; //[14:56:0.1]
fillet_radius_mm = 1; //[0.5:2:0.1]
pipe_wall_thickness_mm = 2.0; //[1.0:4.0:0.1]
pipe_stub_length_mm = 60; //[30:120:0.1]
overlap_mm = 1; //[0.5:2:0.1]
eps_mm = 0.2; //[0.05:0.5:0.05]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    // Outer pipe
    cylinder(r=pipe_outer_diameter_mm/2, h=pipe_stub_length_mm, center=true);
    // Inner pipe
    translate([0, 0, -eps_mm/2])
      cylinder(r=(pipe_outer_diameter_mm/2) - pipe_wall_thickness_mm, h=pipe_stub_length_mm + eps_mm, center=true);
  }
}

// Cap with pipe assembly
module cap_with_pipe() {
  color([0.85, 0.85, 0.8]) {
    // Cap body
    difference() {
      cylinder(r=cap_outer_diameter_mm/2, h=socket_depth_mm + end_thickness_mm, center=true);
      translate([0, 0, (socket_depth_mm + eps_mm)/2 - (socket_depth_mm + end_thickness_mm)/2])
        cylinder(r=socket_inner_diameter_mm/2, h=socket_depth_mm + eps_mm, center=true);
      translate([0, 0, (- (socket_depth_mm + end_thickness_mm)/2) + internal_stop_offset_mm + (socket_depth_mm - internal_stop_offset_mm + eps_mm)/2])
        cylinder(r=(socket_inner_diameter_mm/2) - wall_thickness_mm, h=socket_depth_mm - internal_stop_offset_mm + eps_mm, center=true);
    }
    // Fillet (omitted due to performance)
  }
  // Pipe stub
  translate([0, 0, (socket_depth_mm + end_thickness_mm)/2 + pipe_stub_length_mm/2 - overlap_mm])
    ht_pipe();
}

// Final assembly
module assembly() {
  cap_with_pipe();
}

assembly();