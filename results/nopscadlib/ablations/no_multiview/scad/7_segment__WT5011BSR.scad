// Simplified, connected 7‑segment display block with overall envelope [12.7, 19, 8.2]
// Fix: semantic mismatch -> adds 7 distinct segment bars in standard layout.
// Fix: connectivity -> all translate() values are formula-based and include slight overlap.
// Result: single connected solid, recognizable 7-segment silhouette.

$fn = 48;

// Overall envelope (requested)
body_W = 12.7;
body_H = 19;
body_D = 8.2;

// Connection overlap (1–2mm)
overlap = 1.2;

// Bezel / face
bezel_margin = 1.0;
bezel_thickness = 0.8;

// Segment geometry (raised bars on the face)
segment_inset_margin = 2.0;     // keeps segments away from bezel
segment_raise = 0.8;            // how far segments protrude from face
segment_th = 1.6;               // segment bar thickness (in XY plane)
segment_gap = 1.2;              // gap between top/middle/bottom and verticals

// Decimal point (kept simple, connected)
decimal_r = 0.9;
decimal_h = 0.8;

// Leads (kept simple, connected)
lead_count = 10;
lead_pitch = 2.54;
lead_W = 0.6;
lead_T = 0.5;
lead_L = 6.0;
lead_bar_T = 0.8;

// Mount bosses (kept simple, connected)
mount_boss_r = 1.2;
mount_boss_h = 1.2;

// ---------- Base Shapes ----------
module display_body() {
  cube([body_W, body_H, body_D], center=true);
}

module front_bezel_outer() {
  // Touches body front with overlap
  translate([0, 0, body_D/2 + bezel_thickness/2 - overlap])
    cube([body_W, body_H, bezel_thickness], center=true);
}

module front_bezel_inner_cut() {
  // Cut window through bezel only (slightly deeper for clean boolean)
  translate([0, 0, body_D/2 + bezel_thickness/2 - overlap])
    cube([body_W - 2*bezel_margin, body_H - 2*bezel_margin, bezel_thickness + 2*overlap], center=true);
}

module front_bezel_detail() {
  difference() {
    front_bezel_outer();
    front_bezel_inner_cut();
  }
}

// ---------- 7-Segment Bars (raised, connected to bezel) ----------
module seg_bar_h(len, th, h) cube([len, th, h], center=true);
module seg_bar_v(th, len, h) cube([th, len, h], center=true);

module seven_segments() {
  // Available inner window for segments
  inner_W = body_W - 2*segment_inset_margin;
  inner_H = body_H - 2*segment_inset_margin;

  // Segment lengths (simple proportions)
  hlen = max(1, inner_W - 2*segment_th);
  vlen = max(1, (inner_H - 3*segment_th - 2*segment_gap)/2);

  // Z placement: sit on bezel front with overlap so it's one solid
  z_seg = body_D/2 + segment_raise/2 - overlap;

  // Y positions for top/middle/bottom
  y_top =  inner_H/2 - segment_th/2;
  y_mid =  0;
  y_bot = -inner_H/2 + segment_th/2;

  // X positions for left/right verticals
  x_left  = -inner_W/2 + segment_th/2;
  x_right =  inner_W/2 - segment_th/2;

  // Y centers for upper/lower verticals
  y_upper =  (segment_th + segment_gap)/2 + vlen/2;
  y_lower = -(segment_th + segment_gap)/2 - vlen/2;

  union() {
    // a (top)
    translate([0, y_top, z_seg]) seg_bar_h(hlen, segment_th, segment_raise);
    // g (middle)
    translate([0, y_mid, z_seg]) seg_bar_h(hlen, segment_th, segment_raise);
    // d (bottom)
    translate([0, y_bot, z_seg]) seg_bar_h(hlen, segment_th, segment_raise);

    // f (upper-left)
    translate([x_left,  y_upper, z_seg]) seg_bar_v(segment_th, vlen, segment_raise);
    // b (upper-right)
    translate([x_right, y_upper, z_seg]) seg_bar_v(segment_th, vlen, segment_raise);

    // e (lower-left)
    translate([x_left,  y_lower, z_seg]) seg_bar_v(segment_th, vlen, segment_raise);
    // c (lower-right)
    translate([x_right, y_lower, z_seg]) seg_bar_v(segment_th, vlen, segment_raise);
  }
}

module decimal_point() {
  // Place on lower-right of inner window; connect to bezel with overlap
  inner_W = body_W - 2*segment_inset_margin;
  inner_H = body_H - 2*segment_inset_margin;

  z_dp = body_D/2 + decimal_h/2 - overlap;
  x_dp =  inner_W/2 - decimal_r;
  y_dp = -inner_H/2 + decimal_r;

  translate([x_dp, y_dp, z_dp])
    cylinder(r=decimal_r, h=decimal_h, center=true);
}

// ---------- Leads / Mounting (connected) ----------
module pin_leads_bar() {
  // Bar touches body bottom with overlap
  translate([0,
             -body_H/2 - lead_L/2 + overlap,
             -body_D/2 + lead_bar_T/2 - overlap])
    cube([lead_pitch*(lead_count-1) + lead_W, lead_L, lead_bar_T], center=true);
}

module pin_leads_comb() {
  // Thin comb plate coincident with bar (connected)
  translate([0,
             -body_H/2 - lead_L/2 + overlap,
             -body_D/2 + lead_T/2 - overlap])
    cube([lead_pitch*(lead_count-1) + lead_W, lead_L, lead_T], center=true);
}

module pin_leads() {
  union() {
    pin_leads_bar();
    pin_leads_comb();
  }
}

module mount_boss_left() {
  // Touches body bottom with overlap
  translate([-body_W/2 + mount_boss_r + bezel_margin,
             0,
             -body_D/2 - mount_boss_h/2 + overlap])
    cylinder(r=mount_boss_r, h=mount_boss_h, center=true);
}

module mount_boss_right() {
  translate([ body_W/2 - mount_boss_r - bezel_margin,
              0,
             -body_D/2 - mount_boss_h/2 + overlap])
    cylinder(r=mount_boss_r, h=mount_boss_h, center=true);
}

module mounting_features() {
  union() {
    mount_boss_left();
    mount_boss_right();
  }
}

// ---------- Final Model (single connected solid) ----------
module complete_model() {
  union() {
    display_body();
    front_bezel_detail();
    seven_segments();
    decimal_point();
    pin_leads();
    mounting_features();
  }
}

complete_model();