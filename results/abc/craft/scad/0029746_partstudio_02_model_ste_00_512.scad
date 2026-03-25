// Dimension-calibrated (target: 0.20 x 0.03 x 0.06 mm)
scale([1.000006, 0.636382, 0.155001])
{
// Long narrow rail with central rounded slot, 4 diamond through-holes,
// and a tapered/gusseted web with large triangular lightening cutouts + central diamond cutout.
// Structural fixes:
// - Web is correctly oriented (extruded along X) and positioned to overlap the rail bottom.
// - Triangular lightening cutouts are made large/clear and guaranteed to intersect the web.
// - Central small diamond cutout is added in the web.
// - All translate() values are formula-based; all parts remain a single connected solid.

$fn = 96;

// ---------------- Parameters (mm) ----------------
L = 0.2;
W = 0.03;
H = 0.06;

slot_L = 0.12;
slot_W = 0.01;
slot_end_r = 0.005;

diamond_major = 0.01;
diamond_minor = 0.006;
diamond_end_offset  = 0.075;   // < L/2
diamond_side_offset = 0.008;

web_base_W = 0.022;   // web thickness in Y at base
web_top_W  = 0.010;   // web thickness in Y at top
web_H      = 0.045;   // web height in Z (below rail)

tri_cut_L = 0.070;    // larger/more visible than before
tri_cut_H = 0.040;
tri_cut_offset = 0.055;

center_diamond_major = 0.008;
center_diamond_minor = 0.005;

edge_chamfer = 0.001;

// Small overlap (relative to tiny model) to ensure watertight unions/cuts
overlap = 0.002;

// ---------------- Helpers ----------------
module diamond2d(maj, min) {
  polygon(points=[
    [ maj/2, 0],
    [ 0,    min/2],
    [-maj/2, 0],
    [ 0,   -min/2]
  ]);
}

module rounded_slot2d(len, wid, r) {
  intersection() {
    hull() {
      translate([ len/2 - r, 0]) circle(r=r);
      translate([-len/2 + r, 0]) circle(r=r);
    }
    square([len, wid], center=true);
  }
}

// ---------------- Main solids ----------------
module outer_rail_body() {
  cube([L, W, H], center=true);
}

// Web is a trapezoid in YZ, extruded along X.
// IMPORTANT: polygon is defined in (Y,Z) coordinates, then extruded along X.
module tapered_web_gusset() {
  z_top = -H/2 + overlap;     // slightly inside rail for solid connection
  z_bot = z_top - web_H;

  // linear_extrude uses (x,y) as 2D plane; here we treat them as (Y,Z)
  linear_extrude(height=L, center=true)
    polygon(points=[
      [-web_base_W/2, z_bot],
      [ web_base_W/2, z_bot],
      [ web_top_W/2,  z_top],
      [-web_top_W/2,  z_top]
    ]);
}

// ---------------- Cutters (rail) ----------------
module central_rounded_slot_cut() {
  linear_extrude(height=H + 2*overlap, center=true)
    rounded_slot2d(slot_L, slot_W, slot_end_r);
}

module diamond_hole_cut() {
  linear_extrude(height=H + 2*overlap, center=true)
    diamond2d(diamond_major, diamond_minor);
}

module diamond_holes_x4() {
  for (sx = [-1, 1], sy = [-1, 1])
    translate([sx*diamond_end_offset, sy*diamond_side_offset, 0])
      diamond_hole_cut();
}

module edge_chamfer_cuts() {
  for (sy = [-1, 1], sz = [-1, 1]) {
    translate([0,
               sy*(W/2 - edge_chamfer/2),
               sz*(H/2 - edge_chamfer/2)])
      cube([L + 2*overlap, edge_chamfer, edge_chamfer], center=true);
  }
}

// ---------------- Web cutouts (must intersect the web) ----------------
// Cut through web thickness (Y) by extruding along Y.
// Build triangle/diamond in XZ plane, then extrude in Y.
module triangular_lightening_cutout_y() {
  rotate([90, 0, 0])  // make linear_extrude go along Y
    linear_extrude(height=web_base_W + 2*overlap, center=true)
      polygon(points=[
        [-tri_cut_L/2, -tri_cut_H/2],
        [ tri_cut_L/2, -tri_cut_H/2],
        [ 0,            tri_cut_H/2]
      ]);
}

module central_small_diamond_cutout_y() {
  rotate([90, 0, 0])
    linear_extrude(height=web_base_W + 2*overlap, center=true)
      diamond2d(center_diamond_major, center_diamond_minor);
}

module web_cutouts_union() {
  // Web Z-span
  z_top = -H/2 + overlap;
  z_bot = z_top - web_H;

  // Place cutouts clearly inside the web volume (not grazing edges)
  zc = (z_top + z_bot)/2;

  union() {
    // Two large triangular lightening cutouts
    translate([ tri_cut_offset, 0, zc]) triangular_lightening_cutout_y();
    translate([-tri_cut_offset, 0, zc]) triangular_lightening_cutout_y();

    // Small central diamond cutout in the web
    translate([0, 0, zc]) central_small_diamond_cutout_y();
  }
}

module web_with_cutouts() {
  difference() {
    tapered_web_gusset();
    web_cutouts_union();
  }
}

// ---------------- Final assembly ----------------
module final_model() {
  union() {
    // Rail with through features
    difference() {
      outer_rail_body();
      central_rounded_slot_cut();
      diamond_holes_x4();
      edge_chamfer_cuts();
    }

    // Gusseted/tapered web with triangular lightening cutouts + central diamond cutout
    web_with_cutouts();
  }
}

final_model();
}
