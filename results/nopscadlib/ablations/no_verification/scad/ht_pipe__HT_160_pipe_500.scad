// Parameters
pipe_standard = 0; //[0:0:1]
nominal_diameter_mm = 160; //[80:320:1]
length_mm = 500; //[250:1000:1]
include_end_fitting = 1; //[0:1:1]
pipe_od = 160; //[80:320:1]
pipe_wall = 4.9; //[2.5:10:0.1]
socket_length = 70; //[35:140:1]
socket_wall_extra = 2.5; //[1:6:0.1]
socket_id_clearance = 1.0; //[0.2:3.0:0.1]
union_overlap = 1.0; //[0.5:2.0:0.1]

$fn = 128;

// HT Pipe - one connected solid (hollow tube with optional socket)
module ht_pipe() {
  // Derived dimensions
  pipe_r  = pipe_od/2;
  pipe_ir = max(0.1, pipe_r - pipe_wall);

  sock_h  = include_end_fitting ? socket_length : 0;
  body_h  = max(0, length_mm - sock_h);

  sock_or = pipe_r + socket_wall_extra;
  // Socket inner radius must be <= socket outer radius
  sock_ir = min(sock_or - 0.1, pipe_r + socket_id_clearance);
  sock_ir = max(0.1, sock_ir);

  // Small epsilon to avoid coplanar artifacts
  eps = max(0.01, union_overlap/10);

  color([0.85, 0.85, 0.8])
  difference() {
    // OUTER solid: body + socket (connected with overlap)
    union() {
      // Main pipe outer
      cylinder(h=body_h + (include_end_fitting ? union_overlap : 0),
               r=pipe_r, center=false);

      // Socket outer (starts at end of body, overlaps by union_overlap)
      if (include_end_fitting)
        translate([0, 0, body_h - union_overlap])
          cylinder(h=sock_h + union_overlap, r=sock_or, center=false);
    }

    // INNER void: continuous bore through body + socket
    union() {
      // Main pipe inner void (extended slightly)
      translate([0, 0, -eps])
        cylinder(h=body_h + (include_end_fitting ? union_overlap : 0) + 2*eps,
                 r=pipe_ir, center=false);

      // Socket inner void (larger ID), aligned and overlapping into body
      if (include_end_fitting)
        translate([0, 0, body_h - union_overlap - eps])
          cylinder(h=sock_h + union_overlap + 2*eps,
                   r=sock_ir, center=false);
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();