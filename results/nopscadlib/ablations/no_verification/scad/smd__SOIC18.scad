// SMD package target overall: [11.40, 7.50, 2.00] (L x W x H)
// One connected solid. Simple body + two end terminations + two corner bumps (as seen in orthographic views).

// ---------- Parameters ----------
L = 11.40;
W = 7.50;
H = 2.00;

// Inner "top" inset (visual feature seen in side/front/back/left/right views)
inset_margin = 0.80;     // frame thickness around inset
inset_depth  = 0.25;     // depth of inset from top surface

// End terminations (kept within overall length; no protrusion beyond L)
term_len   = 1.60;       // along X
term_w     = 6.20;       // along Y
term_thk   = 0.25;       // along Z (bottom pads)

// Corner bumps (small circular protrusions seen in views)
bump_r = 0.60;
bump_h = 0.25;           // height of bump (kept within overall height)

// Connectivity overlap (ensures single connected solid)
overlap = 0.20;
eps = 0.02;
$fn = 64;

// ---------- Helpers ----------
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// Inset size (must remain positive)
inset_L = clamp(L - 2*inset_margin, 0.1, L);
inset_W = clamp(W - 2*inset_margin, 0.1, W);
inset_depth_c = clamp(inset_depth, 0, H);

// Termination placement (fully inside overall length)
term_xL = -L/2 + term_len/2;
term_xR =  L/2 - term_len/2;

// Bottom pad Z placement: slightly overlaps into body
term_z = -H/2 + term_thk/2 + overlap/2;

// Bump Z placement: on top surface, slightly overlapping into body
bump_z = H/2 - bump_h/2 - overlap/2;

// Corner bump XY positions (at corners, slightly inset so they don't exceed overall footprint)
bump_inset = bump_r; // keeps bump within L/W
bump_xy = [
  [-L/2 + bump_inset,  W/2 - bump_inset], // top-left
  [ L/2 - bump_inset, -W/2 + bump_inset]  // bottom-right
];

// ---------- Geometry ----------
module body_main() {
  cube([L, W, H], center=true);
}

module top_inset_cut() {
  translate([0, 0, H/2 - inset_depth_c/2 + eps/2])
    cube([inset_L, inset_W, inset_depth_c + eps], center=true);
}

module termination(xc) {
  translate([xc, 0, term_z])
    cube([term_len, term_w, term_thk + overlap], center=true);
}

module terminations() {
  union() {
    termination(term_xL);
    termination(term_xR);
  }
}

module corner_bumps() {
  union() {
    for (p = bump_xy)
      translate([p[0], p[1], bump_z])
        cylinder(r=bump_r, h=bump_h + overlap, center=true);
  }
}

// ---------- Final (ONE connected solid) ----------
union() {
  difference() {
    body_main();
    top_inset_cut();
  }
  terminations();
  corner_bumps();
}