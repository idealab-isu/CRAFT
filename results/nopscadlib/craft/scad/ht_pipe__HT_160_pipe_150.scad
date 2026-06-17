// Parameters
pipe_standard = 1; //[1:1:1]
nominal_size = 160; //[80:320:1]
length_mm = 150; //[75:300:1]
center = 0; //[0:1:1]
pipe_od = 160; //[120:200:0.5]
pipe_wall = 4.7; //[2.5:9.5:0.1]
overlap = 1; //[0.5:2:0.1]
fitting_length = 55; //[30:110:1]
fitting_wall_extra = 2.5; //[1:6:0.1]
fitting_od_extra = 6; //[2:15:0.5]
socket_depth = 40; //[20:80:1]
lead_in_length = 8; //[3:20:1]

$fn = 128;

module ht_pipe() {
  // Radii
  ro_pipe = pipe_od/2;
  ri_pipe = ro_pipe - pipe_wall;

  ro_fit  = ro_pipe + fitting_od_extra/2;

  // Socket ID should be larger than pipe ID by 2*fitting_wall_extra
  ri_socket = ri_pipe + fitting_wall_extra;

  // Robust clamps (avoid empty/invalid geometry)
  eps = max(0.01, overlap);
  ri_pipe_c   = max(0.01, ri_pipe);
  ri_socket_c = max(ri_pipe_c + 0.01, ri_socket);
  ro_pipe_c   = max(ri_socket_c + 0.5, ro_pipe); // ensure outer > inner
  ro_fit_c    = max(ro_pipe_c + 0.01, ro_fit);

  // Axial layout
  z0 = 0;
  z1 = length_mm;          // end of plain pipe
  z2 = z1 + fitting_length; // end of socket

  // Lead-in at socket mouth (outer end)
  lead = min(lead_in_length, fitting_length - 0.01);
  z_cone0 = z2 - lead;

  // Optional centering
  z_shift = (center == 1) ? -(z2/2) : 0;

  color([0.85, 0.85, 0.8])
  translate([0,0,z_shift])
  difference() {
    // OUTER solid (connected)
    union() {
      // Plain pipe OD
      cylinder(r=ro_pipe_c, h=length_mm, center=false);

      // Socket OD (overlap into pipe by eps)
      translate([0,0,z1 - eps])
        cylinder(r=ro_fit_c, h=fitting_length + eps, center=false);

      // Outer lead-in chamfer at socket mouth
      translate([0,0,z_cone0])
        cylinder(r1=ro_fit_c - lead, r2=ro_fit_c, h=lead, center=false);
    }

    // INNER void (connected)
    union() {
      // Through-bore (pipe ID) through entire part
      translate([0,0,z0 - eps])
        cylinder(r=ri_pipe_c, h=(z2 - z0) + 2*eps, center=false);

      // Socket cavity (larger ID) from pipe end into socket
      translate([0,0,z1 - eps])
        cylinder(r=ri_socket_c, h=socket_depth + 2*eps, center=false);

      // Inner lead-in from socket ID down to pipe ID at socket entrance
      translate([0,0,z1 - eps])
        cylinder(r1=ri_socket_c, r2=ri_pipe_c, h=lead + 2*eps, center=false);
    }
  }
}

ht_pipe();