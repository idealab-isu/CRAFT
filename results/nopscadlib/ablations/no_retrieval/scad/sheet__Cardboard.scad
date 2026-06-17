// Corrugated cardboard sheet (render-friendly)
// Single connected solid: rounded sheet + internal fluted core + optional exposed edge.
// Simplified: removed heavy face groove cutters and redundant booleans.

// ---------------- Parameters ----------------
sheet_L = 300; //[150:600:1]
sheet_W = 200; //[100:400:1]
sheet_T = 4;   //[2:8:0.1]
liner_T = 0.4; //[0.2:0.8:0.05]

flute_pitch = 8; //[4:16:0.5]
flute_amp = 1.6; //[0.8:3.2:0.1]

corner_R = 8; //[2:20:0.5]

edge_detail_depth = 12; //[0:40:1]
edge_detail_on = 1;     //[0:1:1]

// Quality
$fn = 24;

// ---------------- Derived ----------------
eps = 0.02;
core_T = max(0.2, sheet_T - 2*liner_T);

// ---------------- Helpers ----------------
module rounded_rect_prism(L, W, H, R) {
  r = max(0, min(R, min(L, W)/2 - eps));
  linear_extrude(height=H, center=true, convexity=4)
    offset(r=r)
      square([L - 2*r, W - 2*r], center=true);
}

function wave_y(x, pitch, amp) = amp * sin(360 * x / pitch);

module fluted_core_solid(L, W, T, pitch, amp) {
  // 2D X-Z ribbon extruded along Y
  n = max(24, ceil(L / (pitch/2)));   // reduced segments for speed
  dx = L / n;

  a = min(amp, max(0.05, T/2 - eps));

  top_pts = [
    for (i = [0:n])
      let(x = -L/2 + i*dx)
      [x,  T/2 - a + wave_y(x + L/2, pitch, a)]
  ];

  bot_pts = [
    for (i = [n:-1:0])
      let(x = -L/2 + i*dx)
      [x, -T/2 + a + wave_y(x + L/2, pitch, a)]
  ];

  rotate([90,0,0])
    linear_extrude(height=W, center=true, convexity=6)
      polygon(points=concat(top_pts, bot_pts));
}

module edge_flute_window(L, W, T, pitch, amp, depth) {
  d = max(0, depth);
  if (d > 0) {
    // Add a short fluted section at +X edge (unioned, connected)
    translate([L/2 - d/2 + eps, 0, 0])
      fluted_core_solid(d + 2*eps, W + 2*eps, T, pitch, amp);
  }
}

// ---------------- Main model ----------------
module corrugated_cardboard_sheet() {
  union() {
    // Outer sheet
    rounded_rect_prism(sheet_L, sheet_W, sheet_T, corner_R);

    // Internal fluted core (slightly thicker to ensure intersection with liners)
    fluted_core_solid(sheet_L, sheet_W, core_T + 2*eps, flute_pitch, flute_amp);

    // Optional exposed edge detail
    if (edge_detail_on)
      edge_flute_window(sheet_L, sheet_W, core_T + 2*eps, flute_pitch, flute_amp, edge_detail_depth);
  }
}

// ---------------- Final Output ----------------
corrugated_cardboard_sheet();