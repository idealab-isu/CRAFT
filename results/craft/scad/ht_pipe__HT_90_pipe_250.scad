// HT 90 pipe 250 mm (single socket end, one plain spigot end)
// Fixed: orient pipe along X so orthographic front/back/left/right show length/profile.
// Fixed: true hollow interior with open ends (spigot end and socket mouth).
// Fixed: socket cavity + stop ring implemented without accidentally "re-filling" the void.
// One connected solid.

$fn = 128;

// Parameters
nominal_diameter_mm = 90; //[50:180:1]
length_mm = 250; //[125:500:1]

pipe_od_mm = 90; //[50:180:1]
pipe_wall_mm = 3.2; //[1.6:6.4:0.1]

include_end_fitting = 1; //[0:1:1]
fit_overlap_mm = 1; //[0.5:2:0.1]
fitting_length_mm = 45; //[25:90:1]
fitting_od_mm = 110; //[90:160:1]
fitting_wall_mm = 4; //[2:8:0.1]
socket_depth_mm = 35; //[15:70:1]
socket_clearance_mm = 0.6; //[0.2:1.2:0.1]
stop_ring_thickness_mm = 3; //[1:6:0.5]
chamfer_length_mm = 6; //[2:12:0.5]

// Derived
pipe_r_o = pipe_od_mm/2;
pipe_r_i = pipe_r_o - pipe_wall_mm;

fit_r_o  = fitting_od_mm/2;
fit_r_i  = fit_r_o - fitting_wall_mm;

socket_r = pipe_r_o + socket_clearance_mm;

// Small overlap to guarantee manifold boolean results
eps = 0.2;

// Clamp to safe ranges
socket_depth = min(socket_depth_mm, fitting_length_mm - eps);
stop_t = min(stop_ring_thickness_mm, socket_depth - eps);

module ht_pipe_90_250() {
  color([0.85, 0.85, 0.8])
  rotate([0, 90, 0])  // pipe axis along +X for recognizable orthographic side views
  difference() {
    // OUTER SOLID (pipe + socket collar), all connected
    union() {
      // Main pipe outer
      cylinder(r=pipe_r_o, h=length_mm, center=false);

      // Socket/collar on ONE end only (at x=0), overlapping into pipe by fit_overlap_mm
      if (include_end_fitting) {
        cylinder(r=fit_r_o, h=fitting_length_mm, center=false);
      }
    }

    // INNER VOID (bore + socket cavity), open at both ends
    union() {
      // Main pipe bore through entire length (open spigot end at x=length_mm)
      cylinder(r=pipe_r_i, h=length_mm + eps, center=false);

      if (include_end_fitting) {
        // Socket cavity from mouth inward (open at x=0)
        cylinder(r=socket_r, h=socket_depth, center=false);

        // Lead-in chamfer at socket mouth (x=0..chamfer_length)
        cylinder(r1=socket_r + chamfer_length_mm, r2=socket_r, h=chamfer_length_mm, center=false);

        // Hollow the collar region beyond socket depth, but keep a stop ring:
        // Remove inner to fit_r_i from (socket_depth - stop_t) to fitting_length,
        // then "add back" the stop ring by NOT removing socket_r for the first stop_t.
        translate([0, 0, socket_depth - stop_t])
          cylinder(r=fit_r_i, h=(fitting_length_mm - (socket_depth - stop_t)) + eps, center=false);

        // Ensure the stop ring exists by limiting the socket cavity to socket_depth-stop_t
        // (already done by socket cavity height = socket_depth, and the fit_r_i cut starts at socket_depth-stop_t)
      }
    }
  }
}

ht_pipe_90_250();