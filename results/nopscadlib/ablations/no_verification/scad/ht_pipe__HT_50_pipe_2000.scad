// Parameters
nominal_size = 50; //[25:100:1]
length_mm = 2000; //[1000:4000:10]
pipe_od = 50; //[40:80:0.5]
pipe_wall = 1.8; //[1:4:0.1]
fitting_length = 55; //[30:110:1]
fitting_od_scale = 1.18; //[1.05:1.4:0.01]
fitting_wall_scale = 1.25; //[1:2:0.01]
socket_depth = 35; //[15:70:1]
socket_clearance = 0.4; //[0.1:1.2:0.05]
overlap = 1; //[0.5:2:0.1]

$fn = 128;

// HT Pipe - one connected solid (single difference with unioned outer shell)
module ht_pipe() {
  pipe_r = pipe_od/2;
  pipe_ir = max(0.01, pipe_r - pipe_wall);

  fit_od = pipe_od * fitting_od_scale;
  fit_r  = fit_od/2;

  fit_wall = pipe_wall * fitting_wall_scale;
  fit_ir = max(0.01, fit_r - fit_wall);

  // Socket inner radius (where another pipe inserts)
  socket_r = pipe_r + socket_clearance;

  // Ensure socket doesn't exceed fitting inner radius
  socket_r_eff = min(socket_r, fit_ir - 0.01);

  // Z positions (all derived)
  z_pipe0 = 0;
  z_pipe1 = length_mm;

  // Fitting overlaps into pipe by "overlap" to guarantee connectivity
  z_fit0 = z_pipe1 - overlap;
  z_fit1 = z_fit0 + fitting_length;

  // Socket void starts at the fitting mouth and goes inward by socket_depth
  z_socket0 = z_fit1 - socket_depth;
  z_socket1 = z_fit1;

  color([0.85, 0.85, 0.8])
  difference() {
    // OUTER SOLID (connected)
    union() {
      // Main pipe outer
      cylinder(h=length_mm, r=pipe_r, center=false);

      // Outer fitting sleeve (overlapping into pipe)
      translate([0, 0, z_fit0])
        cylinder(h=fitting_length, r=fit_r, center=false);
    }

    // INNER VOIDS (unioned)
    union() {
      // Main pipe bore (open ends)
      translate([0, 0, z_pipe0])
        cylinder(h=length_mm, r=pipe_ir, center=false);

      // Fitting bore (keeps wall thickness in sleeve region)
      translate([0, 0, z_fit0])
        cylinder(h=fitting_length, r=fit_ir, center=false);

      // Socket enlargement near mouth (creates socket step)
      translate([0, 0, z_socket0])
        cylinder(h=socket_depth, r=socket_r_eff, center=false);
    }
  }
}

ht_pipe();