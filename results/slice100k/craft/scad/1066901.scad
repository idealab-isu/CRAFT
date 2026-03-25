$fn = 96;

// Bounding box target: 108 x 31 x 3.5 mm
L = 108.0;
W = 31.0;
T = 3.5;

// Rounded-rectangle main body
corner_r = 6.0;

// Stepped extension (narrower) on one end, ending in a U-notch
step_len   = 18.0;
step_width = 22.0;

// U-notch (open to the end)
notch_depth   = 10.0;
notch_width   = 12.0;
notch_inner_r = 3.0;

// Holes
grid_hole_d  = 5.0;
grid_pitch_x = 18.0;   // between the two columns
grid_pitch_y = 12.0;   // between rows
small_hole_d = 3.0;

// Placement
eps = 0.02;
cut_h = T + 2*eps;

// Helpers
module rounded_rect_2d(len, wid, r) {
  r2 = min(r, min(len, wid)/2);
  hull() {
    translate([ r2,      r2])      circle(r=r2);
    translate([len-r2,   r2])      circle(r=r2);
    translate([ r2,    wid-r2])    circle(r=r2);
    translate([len-r2, wid-r2])    circle(r=r2);
  }
}

module plate_outline_2d() {
  // Main rounded rectangle + stepped extension (connected)
  union() {
    // Main body spans x: [-L/2, +L/2]
    translate([-L/2, -W/2])
      rounded_rect_2d(L, W, corner_r);

    // Step extension on +X end, centered in Y
    translate([L/2 - eps, -step_width/2])
      square([step_len + eps, step_width], center=false);
  }
}

module u_notch_cut_2d() {
  // U-shaped notch open to the +X end of the step
  // Build as a rectangle open to the end plus a semicircular bottom.
  // Step end is at x = L/2 + step_len
  x_end = L/2 + step_len;
  x0 = x_end - notch_depth;

  union() {
    // Rectangular throat (open to end)
    translate([x0, -notch_width/2])
      square([notch_depth + eps, notch_width], center=false);

    // Rounded bottom of the U
    translate([x0 + notch_inner_r, 0])
      circle(r=notch_inner_r);
  }
}

module holes_cut_2d() {
  // Place 2x3 grid near the stepped/notched end (as in reference)
  // Keep it within the main body width and near +X.
  grid_center_x = L/2 - 14.0; // near the step shoulder
  grid_center_y = 0.0;

  // 2 columns (left/right), 3 rows (top/mid/bot)
  for (ix = [-0.5, 0.5], iy = [-1, 0, 1]) {
    translate([grid_center_x + ix*grid_pitch_x, grid_center_y + iy*grid_pitch_y])
      circle(d=grid_hole_d);
  }

  // Small hole near the rounded end (opposite side, near -X)
  small_hole_x = -L/2 + 18.0;
  small_hole_y = 0.0;
  translate([small_hole_x, small_hole_y])
    circle(d=small_hole_d);
}

module bracket() {
  difference() {
    linear_extrude(height=T, center=true)
      plate_outline_2d();

    // Notch cut
    translate([0,0,0])
      linear_extrude(height=cut_h, center=true)
        u_notch_cut_2d();

    // Through holes
    translate([0,0,0])
      linear_extrude(height=cut_h, center=true)
        holes_cut_2d();
  }
}

bracket();