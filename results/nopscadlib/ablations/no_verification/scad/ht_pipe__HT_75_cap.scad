$fn = 128;

// Parameters
nominal_diameter = 75; //[40:150:1]
cap_outer_diameter = 90; //[70:140:1]
socket_inner_diameter = 75; //[60:110:1]
cap_wall_thickness = 3; //[2:8:0.5]
end_thickness = 4; //[2:10:0.5]
socket_depth = 40; //[20:80:1]
chamfer_size = 1.5; //[0.5:5:0.25]
shoulder_height = 2; //[1:6:0.5]
pipe_wall_thickness = 2.2; //[1.2:5:0.1]
pipe_stub_length = 60; //[30:150:1]
overlap = 1; //[0.5:2:0.1]
cap_total_height = 44; //[25:100:1]

// Derived radii
cap_R  = cap_outer_diameter/2;
sock_R = socket_inner_diameter/2;

// Small epsilon to avoid coplanar/zero-thickness artifacts
eps = 0.01;

// HT Pipe stub (male) - hollow tube
module ht_pipe_stub() {
  difference() {
    cylinder(r=sock_R - overlap, h=pipe_stub_length, center=true);
    cylinder(r=sock_R - overlap - pipe_wall_thickness, h=pipe_stub_length + 2*(overlap + eps), center=true);
  }
}

// Cap (female) - closed end + socket cavity + shoulder + lead-in chamfer
module ht_cap() {
  difference() {
    // Outer body
    cylinder(r=cap_R, h=cap_total_height, center=true);

    // Inner void to create cap wall + closed end thickness
    // Keep bottom end solid with thickness = end_thickness
    inner_void_h = cap_total_height - end_thickness + 2*eps;
    inner_void_center_z = (-cap_total_height/2 + end_thickness) + inner_void_h/2;
    translate([0, 0, inner_void_center_z])
      cylinder(r=cap_R - cap_wall_thickness, h=inner_void_h, center=true);

    // Main socket cavity (open at top, stops before closed end)
    socket_center_z = cap_total_height/2 - socket_depth/2;
    translate([0, 0, socket_center_z])
      cylinder(r=sock_R, h=socket_depth + 2*(overlap + eps), center=true);

    // Shoulder ring (reduces ID near the bottom of socket)
    shoulder_center_z = (cap_total_height/2 - socket_depth) + shoulder_height/2;
    translate([0, 0, shoulder_center_z])
      cylinder(r=sock_R - cap_wall_thickness, h=shoulder_height + 2*(overlap + eps), center=true);

    // Lead-in chamfer at opening (slightly flared)
    chamfer_center_z = cap_total_height/2 - chamfer_size/2;
    translate([0, 0, chamfer_center_z])
      cylinder(r1=sock_R + chamfer_size, r2=sock_R, h=chamfer_size + 2*(overlap + eps), center=true);
  }
}

// Assembly as ONE connected solid (pipe stub inserted into socket with overlap)
module assembly() {
  union() {
    ht_cap();

    // Place pipe so its top end penetrates into the socket by overlap
    // Cap top plane: +cap_total_height/2
    // Socket bottom plane: +cap_total_height/2 - socket_depth
    // Pipe top plane: pipe_center_z + pipe_stub_length/2
    // Set pipe top = socket bottom + overlap  => guaranteed intersection
    pipe_center_z = (cap_total_height/2 - socket_depth) + overlap - pipe_stub_length/2;

    translate([0, 0, pipe_center_z])
      ht_pipe_stub();
  }
}

color([0.85, 0.85, 0.8]) assembly();