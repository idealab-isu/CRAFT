// SMD package: 9.90 x 3.90 x 1.25 (L x W x H) — one connected solid

$fn = 48;

// Parameters (mm)
body_length = 9.90;
body_width  = 3.90;
body_height = 1.25;

termination_length    = 1.20;
termination_thickness = 0.08;
termination_inset_y   = 0.25;

marking_length    = 3.50;
marking_width     = 1.60;
marking_thickness = 0.03;

chamfer_size = 0.35;

// Small overlap to guarantee watertight unions/differences
overlap = 0.02;

// Helpers
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// Derived (keep sane)
term_w = clamp(body_width - 2*termination_inset_y, 0.01, body_width);
term_h = body_height + 2*termination_thickness;

// Base shapes
module smd_body() {
  cube([body_length, body_width, body_height], center=true);
}

module pin_termination(side=1) { // side = -1 (left), +1 (right)
  // Ensure termination overlaps into body by 'overlap' so it is connected
  translate([ side*(body_length/2 - termination_length/2 - overlap), 0, 0 ])
    cube([termination_length, term_w, term_h], center=true);
}

module top_marking() {
  // Ensure marking overlaps into body by 'overlap' so it is connected
  translate([0, 0, body_height/2 + marking_thickness/2 - overlap])
    cube([marking_length, marking_width, marking_thickness], center=true);
}

// Chamfer cutouts (subtract from body only, not from terminations)
module chamfer_cutouts() {
  cut_h = body_height + 2*overlap;

  for (sx = [-1, 1], sy = [-1, 1]) {
    translate([ sx*(body_length/2 - chamfer_size/2),
                sy*(body_width/2  - chamfer_size/2),
                0 ])
      cube([chamfer_size, chamfer_size, cut_h], center=true);
  }
}

// Final output: one connected solid
union() {
  // Body with chamfered corners
  difference() {
    smd_body();
    chamfer_cutouts();
  }

  // Terminations (symmetrical, connected with overlap)
  pin_termination(-1);
  pin_termination( 1);

  // Top marking (connected with overlap)
  top_marking();
}