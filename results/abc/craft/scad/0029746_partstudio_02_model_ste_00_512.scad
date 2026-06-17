// Dimension-calibrated (target: 0.20 x 0.03 x 0.06 mm)
scale([1.000000, 0.861111, 1.600000])
{
// Long narrow rail with tapered web, central rounded slot, 4 diamond through-holes,
// triangular lightening cutouts, and small central diamond cutout.
// Units are mm (very small part as given).

$fn = 64;

// Parameters
L = 0.2;                 // overall length (X)
W = 0.03;                // overall width  (Y)
H = 0.06;                // overall height (Z)

beam_thk = 0.012;        // bottom flange thickness (Z)
web_base_thk = 0.01;     // web thickness (Y)
web_peak_h = 0.048;      // web peak height from bottom (Z)

slot_L = 0.11;
slot_W = 0.01;
slot_end_r = 0.005;

diamond_hole_diag_L = 0.01;
diamond_hole_diag_W = 0.006;
diamond_hole_x_offset = 0.07;
diamond_hole_y_offset = 0.008;

tri_cut_L = 0.05;
tri_cut_H = 0.03;
tri_cut_x_offset = 0.055;

small_diamond_diag = 0.008;

eps = 0.001;

// ---------- Helpers ----------
module capsule2d(len, wid, r) {
  // 2D rounded-rectangle (capsule) centered at origin, along X
  // Ensures valid geometry even if r is large.
  rr = min(r, wid/2 - 1e-9, len/2 - 1e-9);
  hull() {
    translate([-(len/2 - rr), 0]) circle(r=rr);
    translate([ (len/2 - rr), 0]) circle(r=rr);
  }
}

module diamond2d(dx, dy) {
  polygon(points=[
    [0,  dy/2],
    [dx/2, 0],
    [0, -dy/2],
    [-dx/2, 0]
  ]);
}

// ---------- Solid body ----------
module main_beam_body() {
  // Bottom flange centered in XY, sitting at bottom of overall height
  translate([0, 0, -H/2 + beam_thk/2])
    cube([L, W, beam_thk], center=true);
}

module tapered_web() {
  // Triangular web in XZ, extruded in Y to web_base_thk, centered at Y=0.
  // Base sits on top of flange.
  z0 = -H/2 + beam_thk;
  z1 = -H/2 + web_peak_h;

  translate([0, 0, 0])
    linear_extrude(height=web_base_thk, center=true)
      polygon(points=[
        [-L/2, z0],
        [ L/2, z0],
        [ 0,   z1]
      ]);
}

// ---------- Cutouts (all are true through-cuts where intended) ----------
module central_rounded_slot_cut() {
  // Through the flange (Z direction), centered at origin in XY.
  // Use a capsule so it reads as a single elongated rounded slot.
  translate([0, 0, 0])
    linear_extrude(height=H + 2*eps, center=true)
      capsule2d(slot_L, slot_W, slot_end_r);
}

module diamond_hole_cut(xo, yo) {
  // Through the flange (Z direction)
  translate([xo, yo, 0])
    linear_extrude(height=H + 2*eps, center=true)
      diamond2d(diamond_hole_diag_L, diamond_hole_diag_W);
}

module triangular_lightening_cutout(xo) {
  // Cut through the web thickness (Y direction), removing a triangular window in XZ.
  // Positioned above flange.
  z0 = -H/2 + beam_thk + eps;
  translate([xo, 0, 0])
    rotate([90, 0, 0])  // extrude along Y
      linear_extrude(height=web_base_thk + 2*eps, center=true)
        polygon(points=[
          [-tri_cut_L/2, z0],
          [ tri_cut_L/2, z0],
          [ 0,           z0 + tri_cut_H]
        ]);
}

module central_small_diamond_cutout() {
  // Small diamond window in the web, cut through Y.
  zc = -H/2 + beam_thk + tri_cut_H*0.55;
  translate([0, 0, 0])
    rotate([90, 0, 0])
      linear_extrude(height=web_base_thk + 2*eps, center=true)
        translate([0, zc])
          diamond2d(small_diamond_diag, small_diamond_diag);
}

// ---------- Final model ----------
module final_model() {
  difference() {
    union() {
      main_beam_body();
      tapered_web();
    }

    // Central elongated rounded slot (single continuous opening)
    central_rounded_slot_cut();

    // Four diamond through-holes near ends (symmetric)
    diamond_hole_cut(-diamond_hole_x_offset,  diamond_hole_y_offset);
    diamond_hole_cut( diamond_hole_x_offset,  diamond_hole_y_offset);
    diamond_hole_cut(-diamond_hole_x_offset, -diamond_hole_y_offset);
    diamond_hole_cut( diamond_hole_x_offset, -diamond_hole_y_offset);

    // Web lightening cutouts + small central diamond
    triangular_lightening_cutout(-tri_cut_x_offset);
    triangular_lightening_cutout( tri_cut_x_offset);
    central_small_diamond_cutout();
  }
}

final_model();
}
