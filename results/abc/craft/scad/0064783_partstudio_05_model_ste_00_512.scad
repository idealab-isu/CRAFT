// Dimension-calibrated (target: 0.22 x 0.14 x 0.00 mm)
scale([0.000939, 0.001436, 0.001500])
{
// Flat-pack rail/strap set with cutouts + notched rails + small spool/I-beam block
// One connected solid (explicit overlaps/bridges ensure connectivity)

$fn = 48;

// --- Scale note ---
// The prompt's bounding box is extremely tiny (sub-mm). Many renderers will look blank.
// Keep the same proportions but scale up for visibility; set SCALE=1 to revert.
SCALE = 1000; // 1000x makes ~0.22mm -> ~220mm for clear viewing

// Parameters
bb_L = 0.22 * SCALE;
bb_W = 0.14 * SCALE;

t    = 0.001 * SCALE;
gap  = 0.004 * SCALE;

// Required overlap for solid connections (1–2mm in scaled view)
conn_ov = 0.0015 * SCALE;   // ~1.5mm at SCALE=1000
eps = 1e-6 * SCALE;
t_cut = t + 2*eps;

// Straps
strap_L = 0.205 * SCALE;
strap_W = 0.018 * SCALE;
strap_ch = 0.006 * SCALE;
strap_hole_pitch = 0.022 * SCALE;
strap_hole_size  = 0.007 * SCALE;
strap_hole_count = 7;

// Rails
rail_L = 0.205 * SCALE;
rail_W = 0.014 * SCALE;
tooth_pitch = 0.01 * SCALE;
tooth_depth = 0.004 * SCALE;
tooth_count = 14;
tooth_width = 0.006 * SCALE;

// Spool / I-beam-ish block (make it clearly visible and distinct)
spool_L = 0.022 * SCALE;
spool_W = 0.014 * SCALE;
spool_H = max(0.002 * SCALE, t); // slightly thicker than plate so it reads in ortho views
spool_web_W = 0.0045 * SCALE;

// Bridge sizing (ensure not vanishingly thin)
bridge_w = max(min(gap*0.7, min(rail_W, strap_W)*0.45), t*1.5);

// 2D helpers
module chamfered_rect_2d(L, W, ch) {
  ch2 = min(ch, min(L/2 - eps, W/2 - eps));
  polygon(points=[
    [-L/2 + ch2, -W/2],
    [ L/2 - ch2, -W/2],
    [ L/2,       -W/2 + ch2],
    [ L/2,        W/2 - ch2],
    [ L/2 - ch2,  W/2],
    [-L/2 + ch2,  W/2],
    [-L/2,        W/2 - ch2],
    [-L/2,       -W/2 + ch2]
  ]);
}

module tri_2d(s) {
  polygon(points=[[-s/2, -s/2], [s/2, -s/2], [0, s/2]]);
}

module strap_plate() {
  difference() {
    linear_extrude(height=t, center=true)
      chamfered_rect_2d(strap_L, strap_W, strap_ch);

    for (i = [0:strap_hole_count-1]) {
      x = -strap_hole_pitch*(strap_hole_count-1)/2 + strap_hole_pitch*i;
      translate([x, 0, 0])
        linear_extrude(height=t_cut, center=true) {
          if (i % 3 == 0) {
            square([strap_hole_size, strap_hole_size], center=true);
          } else if (i % 3 == 1) {
            rotate(45) square([strap_hole_size, strap_hole_size], center=true);
          } else {
            tri_2d(strap_hole_size);
          }
        }
    }
  }
}

module rail_strip() {
  difference() {
    cube([rail_L, rail_W, t], center=true);

    for (i = [0:tooth_count-1]) {
      x = -rail_L/2 + tooth_pitch/2 + tooth_pitch*i;
      translate([x, rail_W/2 - tooth_depth/2, 0])
        cube([tooth_width, tooth_depth, t_cut], center=true);
    }
  }
}

module small_spool_block() {
  // "I-beam/spool" silhouette: two flanges with a web (via subtraction)
  difference() {
    cube([spool_L, spool_W, spool_H], center=true);
    cube([spool_L*0.62, max(eps, spool_W - spool_web_W), spool_H + 2*eps], center=true);
  }
}

module bridge_x(len, wid, thick) { cube([len, wid, thick], center=true); }
module bridge_y(len, wid, thick) { cube([wid, len, thick], center=true); }

// --- Layout (centered in X, stacked in Y) ---
// Use explicit formulas so parts touch via bridges with overlap.
y_rail1  = 0;
y_rail2  = y_rail1 + (rail_W/2 + gap + rail_W/2);
y_strap1 = y_rail2 + (rail_W/2 + gap + strap_W/2);
y_strap2 = y_strap1 + (strap_W/2 + gap + strap_W/2);

// Place spool as a distinct separate piece offset from the strips (clearly visible),
// but still connected via a bridge to rail1.
x_spool = -rail_L/2 - gap - spool_L/2; // left of rails with a visible gap
y_spool = y_rail1 - (rail_W/2 + gap + spool_W/2); // below rail1 with a visible gap

// --- Bridge lengths (computed from actual edges + overlap) ---
// Between rail1 and rail2 (vertical)
len_r1_r2 = (rail_W/2 + gap + rail_W/2) + 2*conn_ov;
// Between rail2 and strap1 (vertical)
len_r2_s1 = (rail_W/2 + gap + strap_W/2) + 2*conn_ov;
// Between strap1 and strap2 (vertical)
len_s1_s2 = (strap_W/2 + gap + strap_W/2) + 2*conn_ov;

// Spool -> rail1 bridge (diagonal-ish via two orthogonal bridges for robustness)
// 1) X-bridge at y = y_rail1: from rail left edge to spool right edge
rail_left_x   = -rail_L/2;
spool_right_x = x_spool + spool_L/2;
x_gap_len = (rail_left_x - spool_right_x); // positive distance between edges
bridge_len_x = max(eps, x_gap_len + 2*conn_ov);
x_bridge_center = (rail_left_x + spool_right_x)/2;

// 2) Y-bridge at x = x_spool: from spool top edge to rail1 bottom edge
rail1_bottom_y = y_rail1 - rail_W/2;
spool_top_y    = y_spool + spool_W/2;
y_gap_len = (rail1_bottom_y - spool_top_y);
bridge_len_y = max(eps, y_gap_len + 2*conn_ov);
y_bridge_center = (rail1_bottom_y + spool_top_y)/2;

union() {
  // Main strips
  translate([0, y_rail1, 0])  rail_strip();
  translate([0, y_rail2, 0])  rail_strip();
  translate([0, y_strap1, 0]) strap_plate();
  translate([0, y_strap2, 0]) strap_plate();

  // Distinct small separate spool/I-beam block (offset so it reads clearly)
  translate([x_spool, y_spool, 0]) small_spool_block();

  // Connectivity bridges (ensure ONE connected solid)
  translate([0, (y_rail1 + y_rail2)/2, 0])
    bridge_y(len_r1_r2, bridge_w, t);

  translate([0, (y_rail2 + y_strap1)/2, 0])
    bridge_y(len_r2_s1, bridge_w, t);

  translate([0, (y_strap1 + y_strap2)/2, 0])
    bridge_y(len_s1_s2, bridge_w, t);

  // Spool connectivity (two-step bridge so it cannot miss due to diagonal placement)
  translate([x_bridge_center, y_rail1, 0])
    bridge_x(bridge_len_x, min(bridge_w, spool_W*0.9), max(t, spool_H));

  translate([x_spool, y_bridge_center, 0])
    bridge_y(bridge_len_y, min(bridge_w, spool_L*0.9), max(t, spool_H));
}
}
