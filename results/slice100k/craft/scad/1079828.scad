// Long thin strip with shallow saddle (V) along LENGTH (x), flat top in plan,
// and subtle underside end steps + mid seam. Bounding box: 61.0 x 12.8 x 5.1 mm.

L = 60.96;  // length (x)
W = 12.77;  // width  (y)
H = 5.08;   // height (z)

// Saddle: underside is LOWEST at center, slightly HIGHER toward ends (subtle V)
saddle_rise = 0.55;      // how much the underside rises at ends vs center
saddle_flat_len = 1.6;   // small flat at center to suggest transition

// Underside localized thickness changes (steps/shoulders) - add material below bottom
end_step_len  = 6.0;
end_step_drop = 0.60;

mid_seam_len  = 2.2;
mid_seam_drop = 0.35;

eps = 0.02;
$fn = 64;

// Base block with flat top; bottom at z=0, top at z=H
module base_body() {
  translate([0, 0, H/2]) cube([L, W, H], center=true);
}

// Create a shallow V-shaped underside by CUTTING a wedge that is thickest at center
// and tapers to ~0 at the ends. This makes the underside higher at ends.
module underside_saddle_cut() {
  // Extrude along width (y). Polygon is in x-z plane.
  // We cut from z=0 upward by an amount that is max at center and ~0 at ends.
  linear_extrude(height=W + 0.4, center=true, convexity=10)
    polygon(points=[
      // bottom edge slightly below 0 to ensure robust boolean
      [-L/2 - 0.2, -0.2],
      [ L/2 + 0.2, -0.2],

      // right end: near zero cut
      [ L/2 + 0.2,  0.0],

      // ramp up to center flat (max cut)
      [ saddle_flat_len/2, saddle_rise],
      [-saddle_flat_len/2, saddle_rise],

      // ramp back down to left end
      [-L/2 - 0.2,  0.0]
    ]);
}

// Add underside steps by unioning extra material below z=0 (connected with overlap)
module underside_end_step(sign=1) {
  translate([sign*(L/2 - end_step_len/2), 0, -end_step_drop/2 + eps])
    cube([end_step_len, W, end_step_drop + 2*eps], center=true);
}

module underside_mid_seam() {
  translate([0, 0, -mid_seam_drop/2 + eps])
    cube([mid_seam_len, W, mid_seam_drop + 2*eps], center=true);
}

// Final solid (single connected piece)
difference() {
  union() {
    base_body();
    underside_end_step(-1);
    underside_end_step( 1);
    underside_mid_seam();
  }
  underside_saddle_cut();
}