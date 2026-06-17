// Parameters
nominal_diameter_mm = 75; //[40:150:1]
outer_diameter_mm = 75; //[50:150:1]
socket_inner_diameter_mm = 72; //[50:145:1]
cap_length_mm = 40; //[20:80:1]
socket_depth_mm = 30; //[15:70:1]
wall_thickness_mm = 2.0; //[1.0:6.0:0.1]
end_face_thickness_mm = 3.0; //[1.5:8.0:0.1]
chamfer_mm = 1.0; //[0.0:3.0:0.1]
tolerance_mm = 0.2; //[0.0:1.0:0.05]
insertion_stop_height_mm = 1.5; //[0.5:4.0:0.1]
insertion_stop_thickness_mm = 2.0; //[1.0:6.0:0.1]
pipe_wall_mm = 2.0; //[1.0:6.0:0.1]
pipe_length_mm = 60; //[20:150:1]
overlap_mm = 1.0; //[0.5:2.0:0.1]

$fn = 128;

// Helpers
function clamp(x, a, b) = x < a ? a : (x > b ? b : x);

// Derived dimensions (robust)
cap_r_outer = outer_diameter_mm/2;
socket_r    = (socket_inner_diameter_mm + tolerance_mm)/2;
cap_r_inner = cap_r_outer - wall_thickness_mm;

pipe_r_outer = socket_r - tolerance_mm/2;   // slightly smaller than socket
pipe_r_inner = pipe_r_outer - pipe_wall_mm;

cap_r_inner_safe  = clamp(cap_r_inner, 0.1, cap_r_outer - 0.1);
pipe_r_inner_safe = clamp(pipe_r_inner, 0.1, pipe_r_outer - 0.1);

// Ensure non-degenerate heights
socket_depth_safe = clamp(socket_depth_mm, 0.1, cap_length_mm - end_face_thickness_mm - 0.1);
end_face_safe     = clamp(end_face_thickness_mm, 0.1, cap_length_mm - socket_depth_safe - 0.1);
inner_void_h      = cap_length_mm - socket_depth_safe - end_face_safe;

// Cap solid (closed end, open socket)
module cap_solid() {
  difference() {
    // Outer cap body
    cylinder(h=cap_length_mm, r=cap_r_outer, center=true);

    // Socket void from bottom up
    translate([0, 0, -cap_length_mm/2 + socket_depth_safe/2])
      cylinder(h=socket_depth_safe + overlap_mm, r=socket_r, center=true);

    // Inner void behind socket (keeps end face thickness)
    if (inner_void_h > 0.01)
      translate([0, 0, -cap_length_mm/2 + socket_depth_safe + inner_void_h/2])
        cylinder(h=inner_void_h + overlap_mm, r=cap_r_inner_safe, center=true);

    // Entry chamfer at socket mouth (bottom)
    chamfer_h = clamp(chamfer_mm, 0, socket_depth_safe);
    if (chamfer_h > 0.001)
      translate([0, 0, -cap_length_mm/2 + chamfer_h/2])
        cylinder(h=chamfer_h + overlap_mm, r1=socket_r + chamfer_h, r2=socket_r, center=true);
  }
}

// Insertion stop ring (inside socket), connected to cap
module insertion_stop_ring() {
  // Place ring near top of socket
  zc = -cap_length_mm/2 + socket_depth_safe - insertion_stop_thickness_mm/2;

  // Keep ring within socket depth
  zc_clamped = clamp(zc,
                     -cap_length_mm/2 + insertion_stop_thickness_mm/2,
                     -cap_length_mm/2 + socket_depth_safe - insertion_stop_thickness_mm/2);

  ring_inner_r = clamp(socket_r - insertion_stop_height_mm, 0.1, socket_r - 0.1);

  difference() {
    translate([0, 0, zc_clamped])
      cylinder(h=insertion_stop_thickness_mm, r=socket_r, center=true);

    translate([0, 0, zc_clamped])
      cylinder(h=insertion_stop_thickness_mm + overlap_mm, r=ring_inner_r, center=true);
  }
}

// Pipe (hollow), positioned to overlap into socket so union is one connected solid
module ht_pipe_solid() {
  difference() {
    cylinder(h=pipe_length_mm, r=pipe_r_outer, center=true);
    cylinder(h=pipe_length_mm + overlap_mm, r=pipe_r_inner_safe, center=true);
  }
}

// Assembly: ONE connected solid (pipe overlaps into socket region)
module assembly() {
  union() {
    cap_solid();
    insertion_stop_ring();

    // Place pipe so its top end is inside socket by overlap_mm
    // Cap bottom face: z = -cap_length_mm/2
    // Socket top plane: z = -cap_length_mm/2 + socket_depth_safe
    // Pipe top plane target: socket top - overlap_mm
    pipe_center_z = (-cap_length_mm/2 + socket_depth_safe - overlap_mm) - pipe_length_mm/2;

    translate([0, 0, pipe_center_z])
      ht_pipe_solid();
  }
}

assembly();