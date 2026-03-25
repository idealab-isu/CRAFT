// Parameters
length_mm = 1000; //[500:2000:10]
ht40_outer_diameter = 40; //[30:80:1]
ht40_wall_thickness = 1.8; //[1:4:0.1]
fitting_length = 45; //[25:90:1]
fitting_od_scale = 1.25; //[1.05:1.6:0.01]
socket_extra_clearance = 0.4; //[0.1:1.2:0.05]
socket_wall_extra = 1.2; //[0.2:3:0.1]
connection_overlap = 1; //[0.5:2:0.1]

$fn = 128;

// Module for the HT Pipe (axis along X so orthographic front/back/left/right show the length)
module ht_pipe() {
  od = ht40_outer_diameter;
  r_out = od/2;
  r_in  = r_out - ht40_wall_thickness;

  fit_od = od * fitting_od_scale;
  r_fit_out = fit_od/2;

  // Socket inner radius: slightly larger than pipe OD/2 minus wall thickness, plus clearance
  r_socket_in = r_in + socket_extra_clearance;

  // Ensure socket has at least some wall thickness
  r_socket_in_clamped = min(r_socket_in, r_fit_out - 0.2);

  // Place socket at +X end, overlapping into main pipe by connection_overlap
  socket_x0 = length_mm - fitting_length - connection_overlap;

  color([0.85, 0.85, 0.8])
  rotate([0, 90, 0])  // make pipe run along X
  union() {
    // Main pipe body (hollow)
    difference() {
      cylinder(h=length_mm, r=r_out, center=false);
      translate([0, 0, -0.01])
        cylinder(h=length_mm + 0.02, r=r_in, center=false);
    }

    // End socket/fitting (hollow), connected via overlap
    translate([0, 0, socket_x0])
      difference() {
        cylinder(h=fitting_length, r=r_fit_out, center=false);
        translate([0, 0, -0.01])
          cylinder(h=fitting_length + 0.02, r=r_socket_in_clamped, center=false);
      }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();