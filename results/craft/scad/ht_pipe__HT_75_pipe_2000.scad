// Parameters
pipe_standard = 0; //[0:0:1]
nominal_diameter_mm = 75; //[40:160:1]
length_mm = 2000; //[1000:4000:10]
include_end_fitting = 1; //[0:1:1]
center = 1; //[0:1:1]
ht75_outer_diameter = 75; //[60:90:0.5]
ht75_wall_thickness = 2.7; //[1.5:5.5:0.1]
fit_overlap = 1; //[0.5:2:0.1]
fitting_length = 55; //[30:110:1]
fitting_outer_diameter = 88; //[80:110:0.5]
fitting_wall_extra = 1.8; //[0.5:4:0.1]
socket_clearance = 0.6; //[0.2:1.5:0.1]
stop_ring_thickness = 3; //[1:8:0.5]
stop_ring_position_from_end = 18; //[8:40:1]

// Quality
$fn = 128;

// Small epsilon to avoid coplanar artifacts
eps = 0.05;

// HT Pipe - complete geometry (ONE connected solid)
module ht_pipe() {
  od = ht75_outer_diameter;
  wt = ht75_wall_thickness;
  id = max(0.01, od - 2*wt);

  fl  = fitting_length;

  // Socket inner radius (where pipe inserts)
  socket_r = od/2 + socket_clearance;

  // Ensure socket wall is not thinner than requested extra
  fitting_or = max(fitting_outer_diameter/2, socket_r + fitting_wall_extra);

  // Total length including fitting
  total_len = length_mm + (include_end_fitting ? fl : 0);

  // Place along X so Front/Back/Left/Right show the long pipe (not just a ring)
  x0 = center ? -total_len/2 : 0;

  // Main pipe starts at x0, fitting starts near the far end and overlaps into pipe
  pipe_x = x0;
  fit_x  = x0 + length_mm - fit_overlap;

  color([0.85, 0.85, 0.8])
  union() {
    // Main pipe (hollow)
    difference() {
      translate([pipe_x, 0, 0])
        rotate([0, 90, 0])
          cylinder(r=od/2, h=length_mm, center=false);

      translate([pipe_x - eps, 0, 0])
        rotate([0, 90, 0])
          cylinder(r=id/2, h=length_mm + 2*eps, center=false);
    }

    // End fitting / socket (hollow, connected via overlap)
    if (include_end_fitting) {
      difference() {
        // Outer socket body
        translate([fit_x, 0, 0])
          rotate([0, 90, 0])
            cylinder(r=fitting_or, h=fl, center=false);

        // Inner cavity: socket region + through-bore continuation
        union() {
          // Socket cavity
          translate([fit_x - eps, 0, 0])
            rotate([0, 90, 0])
              cylinder(r=socket_r, h=fl + 2*eps, center=false);

          // Through-bore continuation (same as pipe ID)
          translate([fit_x - eps, 0, 0])
            rotate([0, 90, 0])
              cylinder(r=id/2, h=fl + 2*eps, center=false);

          // Stop ring band (kept as material by NOT subtracting in this band)
          // Implemented by subtracting the socket cavity in two segments, leaving a ring segment uncut.
          ring_x0 = fit_x + fl - stop_ring_position_from_end - stop_ring_thickness;
          ring_x1 = ring_x0 + stop_ring_thickness;

          // Subtract socket cavity before ring
          if (ring_x0 > fit_x + eps)
            translate([fit_x - eps, 0, 0])
              rotate([0, 90, 0])
                cylinder(r=socket_r, h=(ring_x0 - fit_x) + 2*eps, center=false);

          // Subtract socket cavity after ring
          if (fit_x + fl > ring_x1 + eps)
            translate([ring_x1 - eps, 0, 0])
              rotate([0, 90, 0])
                cylinder(r=socket_r, h=(fit_x + fl - ring_x1) + 2*eps, center=false);
        }
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();