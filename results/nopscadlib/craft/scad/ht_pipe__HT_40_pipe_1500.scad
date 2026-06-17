// HT 40 pipe 1500 mm (one connected solid)
// Fix: center the model on Z so orthographic front/back/left/right views show the full length.

length_mm = 1500; //[750:3000:10]
include_end_fitting = 1; //[0:1:1]
ht40_outer_diameter = 40; //[30:80:1]
ht40_wall_thickness = 1.8; //[1:4:0.1]
overlap_mm = 1; //[0.5:2:0.1]
socket_length = 55; //[30:120:1]
socket_wall_extra = 2.2; //[1:6:0.1]
socket_inner_clearance = 0.6; //[0.2:1.5:0.1]
stop_ring_thickness = 2; //[1:5:0.1]
stop_ring_radial = 1.2; //[0.5:3:0.1]

$fn = 128;

// Derived radii
pipe_r_o = ht40_outer_diameter/2;
pipe_r_i = max(0.01, pipe_r_o - ht40_wall_thickness);

socket_r_o = pipe_r_o + socket_wall_extra;
socket_r_i = pipe_r_o + socket_inner_clearance;

ring_r_o = socket_r_i;
ring_r_i = max(0.01, socket_r_i - stop_ring_radial);

// Z layout (center whole part around Z=0 for visibility in ortho views)
z0 = -length_mm/2;                 // pipe start
z1 =  length_mm/2;                 // pipe end
socket_z0 = z1 - socket_length;    // socket start (at pipe end)
socket_z1 = z1;                    // socket end

module ht_pipe_solid() {
  difference() {
    union() {
      // Main pipe outer
      translate([0, 0, z0])
        cylinder(h=length_mm, r=pipe_r_o, center=false);

      if (include_end_fitting) {
        // Socket outer (overlaps into pipe by overlap_mm)
        translate([0, 0, socket_z0 - overlap_mm])
          cylinder(h=socket_length + overlap_mm, r=socket_r_o, center=false);

        // Stop ring solid (inside socket, near socket start; overlaps for connectivity)
        translate([0, 0, socket_z0 - overlap_mm])
          cylinder(h=stop_ring_thickness + 2*overlap_mm, r=ring_r_o, center=false);
      }
    }

    // Main pipe inner void (extended for clean subtraction)
    translate([0, 0, z0 - overlap_mm])
      cylinder(h=length_mm + 2*overlap_mm, r=pipe_r_i, center=false);

    if (include_end_fitting) {
      // Socket inner void (extended)
      translate([0, 0, socket_z0 - overlap_mm])
        cylinder(h=socket_length + 2*overlap_mm, r=socket_r_i, center=false);

      // Stop ring inner void (creates ring radial thickness)
      translate([0, 0, socket_z0 - 2*overlap_mm])
        cylinder(h=stop_ring_thickness + 4*overlap_mm, r=ring_r_i, center=false);
    }
  }
}

color([0.85, 0.85, 0.8]) ht_pipe_solid();