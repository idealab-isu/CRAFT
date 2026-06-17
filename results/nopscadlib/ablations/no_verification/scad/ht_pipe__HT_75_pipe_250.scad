// Parameters
length_mm = 250; //[125:500:1]
ht75_outer_diameter = 75; //[60:90:0.5]
wall_thickness = 2.7; //[1.5:5.4:0.1]
fitting_length = 45; //[25:90:1]
fitting_outer_diameter = 88; //[75:110:0.5]
fitting_wall_thickness = 3.2; //[2:6.4:0.1]
fitting_stop_thickness = 3; //[1:8:0.5]
fitting_stop_length = 6; //[2:15:0.5]
overlap = 1; //[0.5:2:0.1]

$fn = 128;

module ht_pipe() {
  // Derived radii
  pipe_ro = ht75_outer_diameter/2;
  pipe_ri = pipe_ro - wall_thickness;

  sock_ro = fitting_outer_diameter/2;
  sock_ri = sock_ro - fitting_wall_thickness;

  // Ensure stop ring stays within socket wall
  stop_ro = sock_ri;
  stop_ri = max(0.01, sock_ri - fitting_stop_thickness);

  // Place socket at the BOTTOM end (z=0), pipe continues upward
  // One connected solid: union of outer solids, then subtract one continuous inner void.
  color([0.85, 0.85, 0.8])
  difference() {
    union() {
      // Outer pipe
      translate([0, 0, fitting_length - overlap])
        cylinder(h=length_mm, r=pipe_ro, center=false);

      // Outer socket
      cylinder(h=fitting_length, r=sock_ro, center=false);

      // Internal stop ring (solid annulus) inside socket near its top
      translate([0, 0, fitting_length - fitting_stop_length])
        difference() {
          cylinder(h=fitting_stop_length, r=stop_ro, center=false);
          translate([0, 0, -overlap])
            cylinder(h=fitting_stop_length + 2*overlap, r=stop_ri, center=false);
        }
    }

    // Inner void: socket bore + pipe bore, aligned and overlapping to avoid gaps
    union() {
      // Socket inner bore (open at bottom)
      translate([0, 0, -overlap])
        cylinder(h=fitting_length + 2*overlap, r=sock_ri, center=false);

      // Pipe inner bore (continues upward from socket top)
      translate([0, 0, fitting_length - overlap - overlap])
        cylinder(h=length_mm + 2*overlap, r=pipe_ri, center=false);
    }
  }
}

ht_pipe();