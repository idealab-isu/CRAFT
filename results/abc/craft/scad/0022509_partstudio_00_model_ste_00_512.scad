// Dimension-calibrated (target: 0.06 x 0.03 x 0.03 mm)
scale([0.528307, 0.608701, 0.757599])
{
// Rectangular tray-like housing with recessed panel + long slot
// Structural fixes applied:
// - Slot is a CLEAR through-opening: cut from above top down into the cavity (not just a shallow groove)
// - All translate() values are derived from part dimensions (no arbitrary offsets)
// - Single connected solid: outer tapered body + flange are unioned; all features are subtractive
// - Robust booleans via eps overlaps (scaled to tiny mm dimensions)

$fn = 48;

// --- Target overall size (elongated along X) ---
L = 0.10;   // mm (bounding box X)
W = 0.04;   // mm
H = 0.03;   // mm

// --- Construction parameters ---
wall_t = 0.004;
base_t = 0.004;

taper_inset_per_side = 0.004;   // taper from bottom to top (per side)

flange_overhang = 0.003;
flange_t = 0.003;

recess_depth = 0.008;
recess_margin_L = 0.010;
recess_margin_W = 0.008;

slot_L = 0.070;
slot_W = 0.006;

corner_chamfer = 0.002;

// Robust boolean overlap (relative to tiny model size)
eps = 0.001;   // mm

// ---------- Helpers ----------
module rect2d(x, y) {
  polygon(points=[
    [-x/2, -y/2],
    [ x/2, -y/2],
    [ x/2,  y/2],
    [-x/2,  y/2]
  ]);
}

module tapered_solid(outerL, outerW, height, taper) {
  // Bottom is larger, top is smaller -> tapered side walls
  hull() {
    translate([0,0,-height/2]) linear_extrude(height=eps) rect2d(outerL, outerW);
    translate([0,0, height/2]) linear_extrude(height=eps) rect2d(outerL-2*taper, outerW-2*taper);
  }
}

module tapered_void(innerL, innerW, taper, z0, z1) {
  // Void that follows taper between absolute Z extents z0..z1
  hull() {
    translate([0,0,z0]) linear_extrude(height=eps) rect2d(innerL, innerW);
    translate([0,0,z1]) linear_extrude(height=eps) rect2d(innerL-2*taper, innerW-2*taper);
  }
}

module top_flange() {
  // Slight overhang, connected to body by a small overlap (eps)
  // Flange sits on the top face of the body.
  translate([0,0, (H/2) + (flange_t/2) - (eps/2)])
    cube([L + 2*flange_overhang, W + 2*flange_overhang, flange_t + eps], center=true);
}

module corner_chamfer_wedge(xsgn, ysgn) {
  // 45° corner chamfer through full height (+flange + eps)
  total_h = H + flange_t + 4*eps;
  translate([xsgn*(L/2 - corner_chamfer/2), ysgn*(W/2 - corner_chamfer/2), (flange_t/2)])
    rotate([0,0,45])
      cube([corner_chamfer, corner_chamfer, total_h], center=true);
}

// ---------- Model ----------
module model_core() {
  // Outer tapered body + top flange (single connected solid)
  union() {
    tapered_solid(L, W, H, taper_inset_per_side);
    top_flange();
  }
}

module inner_cavity_cut() {
  // Open-top cavity: remove from just above base to above top to guarantee opening
  innerL = L - 2*wall_t;
  innerW = W - 2*wall_t;

  // Keep base thickness; open all the way through the top (including flange)
  z0 = (-H/2) + base_t;                 // cavity starts above base
  z1 = ( H/2) + flange_t + 3*eps;       // ensure it opens through flange

  tapered_void(innerL, innerW, taper_inset_per_side, z0, z1);
}

module recessed_panel_cut() {
  // Recess is cut DOWN from the top face (Z+), centered
  recessL = L - 2*recess_margin_L;
  recessW = W - 2*recess_margin_W;

  // Cut starts slightly above the top of the flange and goes down recess_depth
  z_top = (H/2) + flange_t + 2*eps;
  z_bot = z_top - recess_depth;

  translate([0,0,(z_top+z_bot)/2])
    cube([recessL, recessW, (z_top - z_bot) + 2*eps], center=true);
}

module slot_through_cut() {
  // Long narrow slot cut within the recess.
  // Cut THROUGH the recessed panel and into the cavity so it reads as an opening.
  // Start above top and extend below the cavity start plane (slight overlap).
  z_top = (H/2) + flange_t + 3*eps;
  z_bot = (-H/2) + base_t - 2*eps;  // into cavity region, but not through base

  translate([0,0,(z_top+z_bot)/2])
    cube([slot_L, slot_W, (z_top - z_bot) + 2*eps], center=true);
}

// ---------- Final boolean ----------
difference() {
  model_core();

  // Tray cavity
  inner_cavity_cut();

  // Recess on the top panel area
  recessed_panel_cut();

  // Visible opening feature: slot through the recessed panel into the cavity
  slot_through_cut();

  // Corner chamfers
  corner_chamfer_wedge( 1,  1);
  corner_chamfer_wedge(-1,  1);
  corner_chamfer_wedge( 1, -1);
  corner_chamfer_wedge(-1, -1);
}
}
