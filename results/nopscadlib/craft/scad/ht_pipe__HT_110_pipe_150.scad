// Parameters
nominal_diameter = 110; //[55:220:1]
length_mm = 150; //[75:300:1]
pipe_od = 110; //[55:220:0.5]
pipe_wall = 3.2; //[1.6:6.4:0.1]
fitting_length = 55; //[28:110:1]
fitting_wall_extra = 2; //[1:4:0.1]
fitting_od_extra = 6; //[3:12:0.5]
socket_clearance = 0.6; //[0.2:1.2:0.1]
stop_ring_thickness = 2; //[1:4:0.1]
stop_ring_depth = 2; //[1:4:0.1]
overlap = 1; //[0.5:2:0.1]

$fn = 128;

module ht_pipe() {
  pipe_r = pipe_od/2;
  pipe_ir = pipe_r - pipe_wall;

  // Socket outer radius (bulge)
  socket_or = pipe_r + fitting_od_extra/2;

  // Socket inner radius (receives pipe)
  socket_ir = pipe_r + socket_clearance;

  // Stop ring: smaller inner radius at the far end of the socket
  stop_ir = socket_ir - stop_ring_depth;

  // Valid radii
  pipe_ir_ok   = max(pipe_ir, 0.01);
  socket_ir_ok = max(socket_ir, 0.01);
  stop_ir_ok   = max(stop_ir, 0.01);

  // Socket region at the end of the pipe
  socket_z0 = length_mm - fitting_length; // start of socket along Z
  socket_z1 = length_mm;                  // end of pipe / end of socket

  // Stop ring placed near the far end of the socket (inside)
  stop_z1 = socket_z1;
  stop_z0 = stop_z1 - stop_ring_thickness;

  color([0.85, 0.85, 0.8])
  difference() {
    // OUTER SOLID (one connected body)
    union() {
      cylinder(h=length_mm, r=pipe_r, center=false);

      // Socket bulge overlaps into pipe to guarantee connectivity
      translate([0, 0, socket_z0 - overlap])
        cylinder(h=fitting_length + overlap, r=socket_or, center=false);
    }

    // INNER VOIDS
    union() {
      // Main pipe bore (through entire length)
      translate([0, 0, -overlap])
        cylinder(h=length_mm + 2*overlap, r=pipe_ir_ok, center=false);

      // Socket cavity (larger ID) for most of socket length
      // Ends before stop ring so the ring remains as material.
      translate([0, 0, socket_z0 - overlap])
        cylinder(h=(fitting_length - stop_ring_thickness) + 2*overlap, r=socket_ir_ok, center=false);

      // Stop ring bore (smaller ID) at the far end of socket
      translate([0, 0, stop_z0 - overlap])
        cylinder(h=stop_ring_thickness + 2*overlap, r=stop_ir_ok, center=false);
    }
  }
}

ht_pipe();