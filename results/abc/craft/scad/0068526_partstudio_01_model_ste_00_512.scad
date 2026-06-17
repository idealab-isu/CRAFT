// Dimension-calibrated (target: 0.03 x 0.02 x 0.02 mm)
scale([0.001000, 0.001000, 0.001000])
{
// Prismatic U-channel cradle with tapered inner walls, top outer chamfers,
// and a bottom relief notch (bridge-like profile).

// Parameters
L = 30;                 // length (X)
W = 20;                 // width  (Y)
H = 20;                 // height (Z)

wall_t = 3;             // minimum side wall thickness

cavity_L = 24;          // cavity length (X)
cavity_W = 14;          // cavity width at top opening (Y)
cavity_depth = 14;      // cavity depth from top (Z)

taper_delta_per_side = 0.5; // cavity narrows by this per side at the bottom (Y)

notch_L = 18;           // bottom relief notch length (X)
notch_W = 12;           // bottom relief notch width  (Y)
notch_H = 6;            // bottom relief notch height (Z)

chamfer = 1;            // outer top edge chamfer size
eps = 0.05;             // small overlap for robust booleans

// ---- Helpers ----
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// Sanitize to avoid degenerate/empty geometry
cavL     = clamp(cavity_L, 0.1, L - 2*wall_t);
cavW_top = clamp(cavity_W, 0.1, W - 2*wall_t);
cavW_bot = clamp(cavity_W - 2*taper_delta_per_side, 0.1, cavW_top);
cavD     = clamp(cavity_depth, 0.1, H - 2*eps);

notL = clamp(notch_L, 0.1, L - 2*eps);
notW = clamp(notch_W, 0.1, W - 2*eps);
notH = clamp(notch_H, 0.1, H - 2*eps);

ch = clamp(chamfer, 0.0, min(W/2 - eps, H/2 - eps));

// ---- Main solids/cutters ----
module body() {
  cube([L, W, H], center=true);
}

// Open-top cavity: extrude along X, profile in Y-Z with taper on inner faces.
// FIX: Make it a true open-top pocket by placing the cutter so its TOP is
// above the body's top face, and its bottom is below the desired pocket depth.
module cavity_cut() {
  open_over = 1.5; // 1–2mm overlap to guarantee open top in boolean
  // Pocket should start at top face (Z=+H/2) and go down cavD.
  // So cutter center Z is: top - cavD/2 + open_over/2
  zc = (H/2) - (cavD/2) + (open_over/2);

  translate([0, 0, zc])
    rotate([0, 90, 0])  // extrusion axis = X
      linear_extrude(height=cavL + 2*eps, center=true, convexity=10)
        polygon(points=[
          // Top edge of cutter is above the body top by open_over
          [-cavW_top/2,  cavD/2 + open_over/2 + eps],
          [ cavW_top/2,  cavD/2 + open_over/2 + eps],
          // Bottom edge reaches full pocket depth (plus eps)
          [ cavW_bot/2, -cavD/2 - eps],
          [-cavW_bot/2, -cavD/2 - eps]
        ]);
}

// Bottom relief notch: rectangular cut from the bottom face upward.
// FIX: Ensure it actually opens to the bottom by extending below Z=-H/2.
module bottom_notch_cut() {
  open_over = 1.5; // overlap to guarantee opening to bottom
  // Notch should start at bottom face (Z=-H/2) and go up notH.
  // So cutter center Z is: bottom + notH/2 - open_over/2
  zc = (-H/2) + (notH/2) - (open_over/2);

  translate([0, 0, zc])
    cube([notL + 2*eps, notW + 2*eps, notH + open_over + 2*eps], center=true);
}

// Outer top edge chamfers along the two long top edges (Y = +/- W/2).
// FIX: Make wedges extend slightly above the top face and slightly into the body.
module top_chamfer_cuts() {
  if (ch > 0) {
    over = 1.5; // overlap for robust subtraction
    rotate([0, 90, 0])
      linear_extrude(height=L + 2*eps, center=true, convexity=10)
        union() {
          // +Y top edge chamfer wedge (in Y-Z plane)
          polygon(points=[
            [ W/2 - ch,  H/2 + over],
            [ W/2 + over, H/2 + over],
            [ W/2 + over, H/2 - ch]
          ]);

          // -Y top edge chamfer wedge
          polygon(points=[
            [-W/2 + ch,  H/2 + over],
            [-W/2 - over, H/2 + over],
            [-W/2 - over, H/2 - ch]
          ]);
        }
  }
}

// ---- Complete model ----
// Single connected solid: body minus open-top cavity, minus bottom notch,
// minus top chamfers.
difference() {
  body();
  cavity_cut();
  bottom_notch_cut();
  top_chamfer_cuts();
}
}
