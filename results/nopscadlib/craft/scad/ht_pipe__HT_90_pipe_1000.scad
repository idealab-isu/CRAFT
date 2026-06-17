$fn = 128;

// Parameters
nominal_diameter = 90; //[50:180:1]
length_mm = 1000; //[500:2000:10]
include_end_fitting = 1; //[0:1:1]
center = 0; //[0:1:1]
pipe_od = 90; //[50:180:1]
pipe_wall = 2.7; //[1.5:6:0.1]
socket_length = 60; //[30:120:1]
socket_wall_extra = 2.5; //[1:6:0.1]
socket_bore_clearance = 0.6; //[0.2:1.5:0.1]
overlap = 1; //[0.5:2:0.1]

module ht_pipe() {
  // Derived radii
  pipe_or = pipe_od/2;
  pipe_ir = pipe_or - pipe_wall;

  socket_or = pipe_or + socket_wall_extra;
  socket_ir = pipe_or + socket_bore_clearance;

  // Safety clamps to avoid invalid geometry
  pipe_ir_safe   = max(0.01, pipe_ir);
  socket_ir_safe = max(0.01, min(socket_ir, socket_or - 0.01));

  // Ensure overlap is valid
  overlap_safe = max(0.01, min(overlap, socket_length - 0.01));

  // Z placement
  z0 = center ? -length_mm/2 : 0;
  z_pipe_start = z0;
  z_pipe_end   = z0 + length_mm;

  // Socket starts at pipe end and overlaps into pipe by "overlap_safe"
  z_socket_start = z_pipe_end - overlap_safe;
  z_socket_end   = z_socket_start + socket_length;

  // One connected solid: outer union minus inner voids
  color([0.85, 0.85, 0.8])
  difference() {
    // OUTER SOLID
    union() {
      // Main pipe outer
      translate([0, 0, z_pipe_start])
        cylinder(h=length_mm, r=pipe_or, center=false);

      // Socket outer (connected via overlap)
      if (include_end_fitting)
        translate([0, 0, z_socket_start])
          cylinder(h=socket_length, r=socket_or, center=false);
    }

    // INNER VOIDS (subtracted)
    // Main pipe inner bore (extend slightly to avoid coplanar faces)
    translate([0, 0, z_pipe_start - overlap_safe])
      cylinder(h=length_mm + 2*overlap_safe, r=pipe_ir_safe, center=false);

    // Socket inner bore (only where socket exists)
    if (include_end_fitting)
      translate([0, 0, z_socket_start - overlap_safe])
        cylinder(h=socket_length + 2*overlap_safe, r=socket_ir_safe, center=false);
  }
}

ht_pipe();