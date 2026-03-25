// Parameters
pipe_standard = 1; //[1:1:1]
nominal_diameter = 110; //[55:220:1]
length_mm = 150; //[75:300:1]
include_end_fitting = 1; //[0:1:1]
pipe_od = 110; //[55:220:1]
pipe_wall = 3.2; //[1.6:6.4:0.1]
overlap = 1; //[0.5:2:0.1]
fitting_length = 45; //[22.5:90:1]
fitting_wall_extra = 2.5; //[1.0:5.0:0.1]
fitting_bore_clearance = 0.8; //[0.2:2.0:0.1]
fitting_stop_thickness = 3; //[1:8:0.5]

$fn = 128;

// HT Pipe - one connected solid, open ends, visible wall thickness
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {

    pipe_r_outer = pipe_od/2;
    pipe_r_inner = max(pipe_r_outer - pipe_wall, 0.2);

    socket_r_outer = pipe_r_outer + fitting_wall_extra;
    socket_r_bore  = pipe_r_outer + fitting_bore_clearance;
    socket_r_bore  = min(socket_r_bore, socket_r_outer - 0.2);

    // Ensure socket fits within length
    socket_len = min(fitting_length, length_mm);
    socket_z0  = length_mm - socket_len;

    // Stop ring thickness cannot exceed socket length
    stop_t = min(fitting_stop_thickness, socket_len);

    difference() {
      // OUTER: main pipe + optional socket (connected by construction)
      union() {
        cylinder(r=pipe_r_outer, h=length_mm, center=false);

        if (include_end_fitting && socket_len > 0)
          translate([0, 0, socket_z0])
            cylinder(r=socket_r_outer, h=socket_len, center=false);
      }

      // INNER: main pipe bore (open both ends)
      translate([0, 0, -overlap])
        cylinder(r=pipe_r_inner, h=length_mm + 2*overlap, center=false);

      // INNER: socket bore enlargement (only within socket)
      if (include_end_fitting && socket_len > 0) {
        translate([0, 0, socket_z0 - overlap])
          cylinder(r=socket_r_bore, h=socket_len + 2*overlap, center=false);

        // Create an internal stop shoulder by NOT enlarging the last stop_t of the socket.
        // (No extra subtraction needed; the main bore already exists there.)
        // This is achieved by limiting the enlarged-bore subtraction to (socket_len - stop_t).
        if (socket_len > stop_t) {
          // Re-add the stop region by subtracting the enlargement only up to socket_len - stop_t
          // (Implemented by replacing the above enlargement with a shorter one)
          // To keep CSG simple, we do it by subtracting a "negative" region: subtract nothing.
          // So we instead override: subtract a shorter enlargement and cancel the full one.
          // Practical approach: do the enlargement as two steps: full then cancel stop region.
          // Cancel stop region by subtracting a cylinder of same size as enlargement from the stop region
          // using difference-of-difference is not available; so we implement correctly by:
          // 1) remove the full enlargement above
          // 2) and do the correct shorter enlargement here.
        }
      }
    }

    // Rebuild with correct stop behavior (single difference block) by wrapping above in a helper:
  }
}

// Helper: correct CSG with stop shoulder (single connected solid)
module ht_pipe_correct() {
  color([0.85, 0.85, 0.8]) {

    pipe_r_outer = pipe_od/2;
    pipe_r_inner = max(pipe_r_outer - pipe_wall, 0.2);

    socket_r_outer = pipe_r_outer + fitting_wall_extra;
    socket_r_bore  = pipe_r_outer + fitting_bore_clearance;
    socket_r_bore  = min(socket_r_bore, socket_r_outer - 0.2);

    socket_len = min(fitting_length, length_mm);
    socket_z0  = length_mm - socket_len;

    stop_t = min(fitting_stop_thickness, socket_len);
    enlarge_len = max(socket_len - stop_t, 0);

    difference() {
      union() {
        cylinder(r=pipe_r_outer, h=length_mm, center=false);

        if (include_end_fitting && socket_len > 0)
          translate([0, 0, socket_z0])
            cylinder(r=socket_r_outer, h=socket_len, center=false);
      }

      // Main bore through entire pipe (open ends)
      translate([0, 0, -overlap])
        cylinder(r=pipe_r_inner, h=length_mm + 2*overlap, center=false);

      // Socket enlarged bore only up to the stop shoulder
      if (include_end_fitting && enlarge_len > 0)
        translate([0, 0, socket_z0 - overlap])
          cylinder(r=socket_r_bore, h=enlarge_len + 2*overlap, center=false);
    }
  }
}

// Assembly
module assembly() {
  ht_pipe_correct();
}

assembly();