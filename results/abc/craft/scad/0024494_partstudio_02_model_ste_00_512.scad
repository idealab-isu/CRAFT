// Dimension-calibrated (target: 0.06 x 0.01 x 0.05 mm)
scale([0.949153, 1.300000, 0.960000])
{
// U-shaped clamp / forked saddle clip (single connected solid)
// Structural fixes:
// - Ensure TWO end through-holes (one near -X end, one near +X end of main body)
// - Holes are clearly through along Y and positioned near the ends (not mid-body)
// - Keep all parts connected with small overlap
// - All translate() values derived from dimensions

$fn = 96;

// -------------------- Parameters --------------------
L = 0.06;  // overall length along X (body + prongs)
W = 0.01;  // overall width along Y
H = 0.05;  // overall height along Z

body_L = 0.034;
body_W = W;
body_H = H;

prong_L = 0.026;
prong_W = 0.0032;
prong_H = H;
gap_W   = 0.0036;

cutout_R = 0.018;          // saddle radius
cutout_center_z = 0.025;   // center height of saddle from bottom of body

hole_D = 0.0016;
// Place holes near each end, but keep them inside the chamfered body
hole_offset_from_end = 0.004;

chamfer = 0.0016;          // heavier faceting amount
overlap = 0.0010;

// -------------------- Helpers --------------------
module octahedron(r=1) {
  polyhedron(
    points=[
      [ r, 0, 0], [-r, 0, 0],
      [ 0, r, 0], [ 0,-r, 0],
      [ 0, 0, r], [ 0, 0,-r]
    ],
    faces=[
      [0,2,4],[2,1,4],[1,3,4],[3,0,4],
      [2,0,5],[1,2,5],[3,1,5],[0,3,5]
    ]
  );
}

module chamfered_box(size=[10,10,10], c=1, center=true) {
  // Faceted/chamfered look via Minkowski with an octahedron (planar facets)
  minkowski() {
    cube([max(0.001, size[0]-2*c), max(0.001, size[1]-2*c), max(0.001, size[2]-2*c)], center=center);
    octahedron(c);
  }
}

module prongs_solid() {
  // Two parallel rectangular prongs extending from +X side of body
  // Ensure they overlap into the body for a solid connection.
  x_prongs = body_L/2 + prong_L/2 - overlap;

  translate([x_prongs, 0, 0]) {
    translate([0, -(gap_W/2 + prong_W/2), 0])
      chamfered_box([prong_L, prong_W, prong_H], c=min(chamfer, prong_W/3), center=true);
    translate([0,  (gap_W/2 + prong_W/2), 0])
      chamfered_box([prong_L, prong_W, prong_H], c=min(chamfer, prong_W/3), center=true);
  }
}

module fork_gap_cut() {
  // Slot between prongs (open from +X end)
  x_gap = body_L/2 + prong_L/2 - overlap;
  translate([x_gap, 0, 0])
    cube([prong_L + 4*overlap, gap_W, prong_H + 4*overlap], center=true);
}

module u_saddle_cut() {
  // U-shaped clamp cut: cylindrical cutout that OPENS to -X side
  // Cylinder axis along Y; subtract only the upper half (semi) and only for x <= x_center.
  zc = -body_H/2 + cutout_center_z;

  // Center one radius in from the -X face so it opens to -X.
  x_center = -body_L/2 + cutout_R;

  intersection() {
    // Full cylinder through Y
    translate([x_center, 0, zc])
      rotate([90, 0, 0])
        cylinder(r=cutout_R, h=body_W + 6*overlap, center=true);

    // Keep only the top half (semi-circle)
    translate([x_center, 0, zc + cutout_R/2])
      cube([2*cutout_R + 6*overlap, body_W + 6*overlap, body_H + 2*cutout_R + 6*overlap], center=true);

    // Keep only the portion that reaches the -X face (open to -X): half-space x <= x_center
    // Implemented as a large cube whose +X face is at x_center.
    translate([x_center - (body_L + prong_L)/2, 0, 0])
      cube([body_L + prong_L + 8*overlap, body_W + 8*overlap, body_H + 8*overlap], center=true);
  }
}

module end_holes_cut() {
  // Through-holes at each end of the MAIN BODY (axis along Y)
  // Explicitly compute each end position to avoid "only one visible" ambiguity.
  x_left  = -body_L/2 + hole_offset_from_end;
  x_right =  body_L/2 - hole_offset_from_end;

  for (xpos = [x_left, x_right]) {
    translate([xpos, 0, 0])
      rotate([90, 0, 0])
        cylinder(r=hole_D/2, h=body_W + 10*overlap, center=true);
  }
}

// -------------------- Main solid --------------------
module clamp_solid() {
  union() {
    chamfered_box([body_L, body_W, body_H], c=chamfer, center=true);
    prongs_solid();

    // Optional extension to reach overall L if body_L+prong_L < L (kept connected)
    extra_L = max(0, L - (body_L + prong_L));
    if (extra_L > 0) {
      // Attach to -X side of body with overlap
      x_extra = -(body_L/2) - extra_L/2 + overlap;
      translate([x_extra, 0, 0])
        chamfered_box([extra_L + 2*overlap, body_W, body_H], c=chamfer, center=true);
    }
  }
}

// -------------------- Final boolean --------------------
difference() {
  clamp_solid();

  // Fork opening
  fork_gap_cut();

  // U-shaped saddle cutout (open to -X)
  u_saddle_cut();

  // End through-holes (both ends)
  end_holes_cut();
}
}
