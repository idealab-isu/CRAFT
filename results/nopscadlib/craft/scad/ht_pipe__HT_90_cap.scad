$fn = 128;

// Parameters
nominal_diameter_mm = 90; //[45:180:1]
pipe_outer_diameter_mm = 90; //[45:180:1]
wall_thickness_mm = 3; //[1.5:6:0.1]
socket_insertion_depth_mm = 40; //[20:80:1]
cap_end_wall_thickness_mm = 4; //[2:8:0.5]
overall_length_mm = 50; //[25:100:1]
lead_in_chamfer_mm = 1; //[0.5:3:0.1]
clearance_mm = 0.4; //[0.1:1.0:0.05]
cap_outer_extra_mm = 2; //[0:6:0.5]
overlap_mm = 1; //[0.5:2:0.1]
pipe_stub_length_mm = 80; //[40:160:1]

// Derived radii
pipe_outer_r   = pipe_outer_diameter_mm/2;
pipe_inner_r   = pipe_outer_r - wall_thickness_mm;
socket_inner_r = pipe_outer_r + clearance_mm;
cap_outer_r    = pipe_outer_r + wall_thickness_mm + cap_outer_extra_mm;

// Clamp to keep a real closed end wall
socket_depth = min(socket_insertion_depth_mm, overall_length_mm - cap_end_wall_thickness_mm);

// HT Pipe (for visualization/fit) - hollow tube
module ht_pipe() {
  difference() {
    cylinder(h=pipe_stub_length_mm, r=pipe_outer_r, center=true);
    cylinder(h=pipe_stub_length_mm + 2*overlap_mm, r=pipe_inner_r, center=true);
  }
}

// HT 90 Cap (end cap) - open socket at one end, closed at the other
module ht_90_cap() {
  difference() {
    // Outer body
    cylinder(h=overall_length_mm, r=cap_outer_r, center=true);

    // Inner socket void: starts at open end plane and stops before closed end wall
    // Open end plane: z = -overall_length_mm/2
    // Socket extends to: z = -overall_length_mm/2 + socket_depth
    translate([0, 0, -overall_length_mm/2 + socket_depth/2 - overlap_mm/2])
      cylinder(h=socket_depth + overlap_mm, r=socket_inner_r, center=true);

    // Lead-in chamfer cut at the open end
    translate([0, 0, -overall_length_mm/2 + lead_in_chamfer_mm/2])
      cylinder(h=lead_in_chamfer_mm, r1=socket_inner_r + lead_in_chamfer_mm, r2=socket_inner_r, center=true);
  }
}

// Final assembly: ONE connected solid (cap + inserted pipe stub)
module assembly() {
  union() {
    ht_90_cap();

    // Place pipe so its top slightly passes the socket end to guarantee overlap/connection
    // Pipe top z = pipe_center_z + pipe_stub_length_mm/2
    // Target top z = (-overall_length_mm/2 + socket_depth) + overlap_mm
    pipe_center_z =
      (-overall_length_mm/2 + socket_depth + overlap_mm) - (pipe_stub_length_mm/2);

    translate([0, 0, pipe_center_z])
      ht_pipe();
  }
}

assembly();