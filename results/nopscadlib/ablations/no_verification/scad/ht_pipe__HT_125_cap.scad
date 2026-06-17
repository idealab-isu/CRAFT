$fn = 128;

// Parameters
nominal_size_mm = 125; //[60:250:1]
pipe_od_mm = 125; //[60:250:1]
cap_outer_diameter_mm = 140; //[70:280:1]
cap_total_length_mm = 60; //[30:120:1]
socket_depth_mm = 45; //[20:90:1]
cap_wall_thickness_mm = 4; //[2:10:0.5]
end_plate_thickness_mm = 6; //[3:20:0.5]
insertion_clearance_mm = 0.5; //[0.1:2:0.1]
lead_in_chamfer_mm = 2; //[0:6:0.5]
stop_ring_thickness_mm = 3; //[1:8:0.5]
pipe_wall_thickness_mm = 4; //[2:10:0.5]
ht_pipe_length_mm = 80; //[30:200:1]
overlap_mm = 1; //[0.5:2:0.5]

// Derived
pipe_or = pipe_od_mm/2;
pipe_ir = pipe_or - pipe_wall_thickness_mm;

cap_or  = cap_outer_diameter_mm/2;
cap_h   = cap_total_length_mm;

socket_r = pipe_or + insertion_clearance_mm;

// Cap is centered at Z=0.
// Define "mouth" (open end) at +Z, "closed end" at -Z.
z_mouth  =  cap_h/2;
z_closed = -cap_h/2;

// Clamp to keep geometry valid
socket_depth = min(socket_depth_mm, cap_h - end_plate_thickness_mm);
lead_in = min(lead_in_chamfer_mm, socket_depth);

// Key Z positions
z_socket_bottom = z_mouth - socket_depth;                 // deepest point of socket
z_cavity_center = (z_mouth + (z_closed + end_plate_thickness_mm))/2;
cavity_h        = (cap_h - end_plate_thickness_mm);

// Stop ring: create an internal shoulder by reducing radius for a short band near socket bottom
z_stop_center = z_socket_bottom + stop_ring_thickness_mm/2;

// HT Pipe (for assembly union) - centered at its own origin
module ht_pipe() {
  difference() {
    cylinder(r=pipe_or, h=ht_pipe_length_mm, center=true);
    cylinder(r=pipe_ir, h=ht_pipe_length_mm + 2*overlap_mm, center=true);
  }
}

// Cap body (single solid)
module ht_125_cap_body() {
  difference() {
    // Outer cap
    cylinder(r=cap_or, h=cap_h, center=true);

    // Main internal cavity: from mouth down to just before end plate
    translate([0, 0, z_cavity_center])
      cylinder(r=socket_r, h=cavity_h + 2*overlap_mm, center=true);

    // Lead-in chamfer at mouth (flares outward)
    translate([0, 0, z_mouth - lead_in/2])
      cylinder(r1=socket_r + lead_in, r2=socket_r, h=lead_in + 2*overlap_mm, center=true);

    // Stop shoulder: remove a short section with slightly smaller radius to leave a ring/step
    // (i.e., cavity is socket_r everywhere except this band, which is socket_r - cap_wall_thickness_mm)
    translate([0, 0, z_stop_center])
      cylinder(r=max(0.1, socket_r - cap_wall_thickness_mm), h=stop_ring_thickness_mm + 2*overlap_mm, center=true);
  }
}

// Assembly: ONE connected solid (cap + inserted pipe)
module assembly() {
  // Place pipe so its top end reaches slightly past socket bottom to guarantee overlap with cap interior
  pipe_center_z = (z_socket_bottom + overlap_mm) - ht_pipe_length_mm/2;

  union() {
    ht_125_cap_body();
    translate([0, 0, pipe_center_z]) ht_pipe();
  }
}

assembly();