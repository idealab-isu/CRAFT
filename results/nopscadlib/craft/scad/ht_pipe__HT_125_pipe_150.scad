$fn = 128;

// Parameters
length_mm = 150; //[75:300:1]
outer_diameter_mm = 125; //[100:250:1]
wall_thickness_mm = 3.2; //[1.6:6.4:0.1]
inner_diameter_mm = 118.6; //[90:240:0.1]
include_socket_end = 1; //[0:1:1]
socket_length_mm = 50; //[25:100:1]
socket_outer_diameter_mm = 140; //[120:280:1]
socket_wall_thickness_mm = 4; //[2:8:0.1]
socket_inner_diameter_mm = 132; //[110:270:0.1]
overlap_mm = 1; //[0.5:2:0.1]

// Derived (prefer thickness-driven IDs if user changes thickness)
inner_d_from_thickness = outer_diameter_mm - 2*wall_thickness_mm;
socket_inner_d_from_thickness = socket_outer_diameter_mm - 2*socket_wall_thickness_mm;

pipe_id = min(inner_diameter_mm, inner_d_from_thickness);
socket_id = min(socket_inner_diameter_mm, socket_inner_d_from_thickness);

pipe_or = outer_diameter_mm/2;
pipe_ir = pipe_id/2;

socket_or = socket_outer_diameter_mm/2;
socket_ir = socket_id/2;

// Ensure valid, visible geometry
eps = 0.01;
pipe_ir_safe   = max(eps, min(pipe_ir,   pipe_or - eps));
socket_ir_safe = max(eps, min(socket_ir, socket_or - eps));

module tube(h, ro, ri) {
  difference() {
    cylinder(h=h, r=ro, center=false);
    translate([0,0,-overlap_mm])
      cylinder(h=h + 2*overlap_mm, r=ri, center=false);
  }
}

// Complete HT Pipe with optional socket (ONE connected solid)
module ht_pipe() {
  color([0.85, 0.85, 0.8])
  union() {
    // Main pipe
    tube(length_mm, pipe_or, pipe_ir_safe);

    // Socket end connected by overlap
    if (include_socket_end)
      translate([0, 0, length_mm - overlap_mm])
        tube(socket_length_mm, socket_or, socket_ir_safe);
  }
}

ht_pipe();