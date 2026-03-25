// Dimension-calibrated (target: 0.13 x 0.05 x 0.05 mm)
scale([0.133000, 0.050000, 0.050000])
{
// Offset link/lever: two circular bosses of different thicknesses connected by a long rectangular bar,
// forming an L-shaped side profile. Includes through hex holes in each boss.
// Units: mm

$fn = 96;

// --- Target overall bounding box (approx) ---
L_total = 0.10;   // overall length (X)
W_total = 0.10;   // overall width  (Y)
H_total = 0.10;   // overall height (Z)

// --- Boss geometry ---
boss_large_d = 0.060;
boss_small_d = 0.045;

boss_large_t = 0.060;   // thickness (Z)
boss_small_t = 0.035;

// --- Bar geometry (thin web) ---
bar_w = 0.030;          // width (Y)
bar_t = 0.020;          // thickness (Z)

// --- Placement along X ---
end_margin = 0.010;     // distance from boss outer edge to overall end

// Overlap: keep proportional to tiny 0.1mm part (NOT 1-2mm here, would destroy geometry)
overlap = 0.002;        // small overlap to guarantee connectivity (mm)

// Derived boss centers so overall length is L_total
x_large = -L_total/2 + end_margin + boss_large_d/2;
x_small =  L_total/2 - end_margin - boss_small_d/2;

// Bar spans between OUTER edges of bosses (with overlap into bosses)
bar_L = (x_small - x_large) - (boss_large_d/2 + boss_small_d/2) + 2*overlap;
bar_L = max(bar_L, overlap*6); // safety

// --- L-offset in Z (creates L-shaped side view) ---
// Put bar + small boss on lower level; large boss on higher level.
// Ensure the large boss bottom overlaps the bar top by 'overlap' for a watertight union.
z_bar   = bar_t/2;
z_small = boss_small_t/2;
z_large = (bar_t/2 + boss_large_t/2) - overlap; // bottom of large boss = bar top - overlap

// --- Hex holes (across flats) ---
hex_large_af = 0.020;
hex_small_af = 0.016;
hex_clearance = 0.001;

// Convert across-flats to circumscribed radius for a 6-sided polygon
function hex_R(af) = (af + hex_clearance) / sqrt(3);

module hex_prism(af, h) {
  cylinder(h=h, r=hex_R(af), $fn=6, center=true);
}

module boss(d, t, x, z) {
  translate([x, 0, z])
    cylinder(d=d, h=t, center=true);
}

module bar_web() {
  // Bar centered between boss OUTER edges, at bar level
  translate([(x_large + x_small)/2, 0, z_bar])
    cube([bar_L, bar_w, bar_t], center=true);
}

module transition_web() {
  // A solid "step" near the large boss that connects the lower bar up to the higher large boss.
  // Use hull between two pads at different Z levels to create a sloped/stepped web.
  //
  // Recalculated to guarantee overlap into BOTH the large boss and the bar.
  x_pad_large = x_large + boss_large_d/2 - overlap; // inside large boss outer edge
  x_pad_bar   = x_pad_large + max(bar_L*0.40, overlap*10); // extends into bar region

  hull() {
    // pad at bar level (overlaps bar)
    translate([x_pad_bar, 0, z_bar])
      cube([overlap*2, bar_w, bar_t], center=true);

    // pad at large boss level (overlaps large boss)
    translate([x_pad_large, 0, z_large])
      cube([overlap*2, bar_w, boss_large_t], center=true);
  }
}

module body() {
  union() {
    // Bosses
    boss(boss_large_d, boss_large_t, x_large, z_large);
    boss(boss_small_d, boss_small_t, x_small, z_small);

    // Long rectangular connecting bar between bosses
    bar_web();

    // L-offset transition near the large boss
    transition_web();
  }
}

module holes() {
  union() {
    // Through hex holes (through each boss thickness)
    translate([x_large, 0, z_large])
      hex_prism(hex_large_af, boss_large_t + 8*overlap);

    translate([x_small, 0, z_small])
      hex_prism(hex_small_af, boss_small_t + 8*overlap);
  }
}

// Final model: one connected solid with through hex holes
difference() {
  body();
  holes();
}
}
