// Flat-pack rail/strap set (single connected solid) - fast render, simplified booleans

// ---------------- Parameters ----------------
bb_x = 0.22; //[0.11:0.44:0.001]
bb_y = 0.14; //[0.07:0.28:0.001]

// Make thickness visible (original 0.001 often renders as a line)
t = 0.004; //[0.001:0.01:0.0005]

gap_y = 0.004; //[0.002:0.008:0.0005]
overlap = 0.001; //[0.0005:0.002:0.0001]
bridge_w = 0.002; //[0.001:0.004:0.0005]

strap_L = 0.205; //[0.1025:0.41:0.001]
strap_W = 0.018; //[0.009:0.036:0.0005]
strap_ch = 0.004; //[0.002:0.008:0.0005]
strap_hole_pitch = 0.02; //[0.01:0.04:0.001]
strap_hole_count = 7; //[3:14:1]
hole_sq = 0.006; //[0.003:0.012:0.0005]
hole_tri = 0.007; //[0.0035:0.014:0.0005]
hole_dia = 0.008; //[0.004:0.016:0.0005]

rail_L = 0.205; //[0.1025:0.41:0.001]
rail_W = 0.014; //[0.007:0.028:0.0005]
tooth_pitch = 0.01; //[0.005:0.02:0.0005]
tooth_w = 0.006; //[0.003:0.012:0.0005]
tooth_d = 0.004; //[0.002:0.008:0.0005]
tooth_count = 16; //[6:32:1]

spool_L = 0.02; //[0.01:0.04:0.001]
spool_W = 0.01; //[0.005:0.02:0.0005]
spool_web_W = 0.004; //[0.002:0.008:0.0005]

layout_margin_x = 0.007; //[0.003:0.014:0.0005]
layout_margin_y = 0.01; //[0.005:0.02:0.0005]

// ---------------- Helpers ----------------
function strapA_y() =  bb_y/2 - layout_margin_y - strap_W/2;
function strapB_y() =  bb_y/2 - layout_margin_y - strap_W - gap_y - strap_W/2;

function railA_y()  = -bb_y/2 + layout_margin_y + rail_W/2;
function railB_y()  = -bb_y/2 + layout_margin_y + rail_W + gap_y + rail_W/2;

function spool_x()  = -bb_x/2 + layout_margin_x + spool_L/2;

// ---------------- 2D primitives ----------------
module strap_2d(L, W, ch) {
  ch2 = max(0, min(ch, (min(L, W) / 2) - 1e-6));
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

module diamond_2d(d) {
  polygon(points=[[0, d/2], [d/2, 0], [0, -d/2], [-d/2, 0]]);
}

module tri_2d(s) {
  polygon(points=[[0, s/2], [s/2, -s/2], [-s/2, -s/2]]);
}

// ---------------- Parts (2D) ----------------
module straps_2d() {
  union() {
    translate([0, strapA_y()]) strap_2d(strap_L, strap_W, strap_ch);
    translate([0, strapB_y()]) strap_2d(strap_L, strap_W, strap_ch);
  }
}

module strap_holes_2d(ypos, phase=0) {
  x0 = -strap_L/2 + strap_ch + strap_hole_pitch;
  x1 =  strap_L/2 - strap_ch - strap_hole_pitch;
  n  = max(0, strap_hole_count);
  step = (n > 1) ? ((x1 - x0) / (n - 1)) : 0;

  for (i = [0:n-1]) {
    xi = x0 + i*step;
    translate([xi, ypos])
      ( ((i+phase) % 3 == 0) ? diamond_2d(hole_dia)
      : ((i+phase) % 3 == 1) ? square([hole_sq, hole_sq], center=true)
                             : tri_2d(hole_tri) );
  }
}

module strap_holes_all_2d() {
  union() {
    strap_holes_2d(strapA_y(), 0);
    strap_holes_2d(strapB_y(), 1);
  }
}

module rails_2d() {
  union() {
    translate([0, railA_y()]) square([rail_L, rail_W], center=true);
    translate([0, railB_y()]) square([rail_L, rail_W], center=true);
  }
}

module rail_notches_2d(ypos) {
  y_edge = ypos + rail_W/2;
  x0 = -rail_L/2 + tooth_pitch;
  x1 =  rail_L/2 - tooth_pitch;
  n  = max(0, tooth_count);
  step = (n > 1) ? ((x1 - x0) / (n - 1)) : 0;

  for (i = [0:n-1]) {
    xi = x0 + i*step;
    translate([xi, y_edge - tooth_d/2])
      square([tooth_w, tooth_d], center=true);
  }
}

module rail_notches_all_2d() {
  union() {
    rail_notches_2d(railA_y());
    rail_notches_2d(railB_y());
  }
}

module spool_2d() {
  y_mid = (railA_y() + railB_y())/2;
  translate([spool_x(), y_mid])
    union() {
      translate([-spool_L/3, 0]) square([spool_L/3, spool_W], center=true);
      translate([ spool_L/3, 0]) square([spool_L/3, spool_W], center=true);
      square([spool_L, spool_web_W], center=true);
    }
}

// ---------------- Connectivity bridges (2D) ----------------
module bridge_between_2d(y1, y2, x_at, w=bridge_w) {
  ymid = (y1 + y2)/2;
  h = abs(y1 - y2) + min(strap_W, rail_W) - overlap*2;
  translate([x_at, ymid]) square([w, max(0, h)], center=true);
}

module bridge_horizontal_2d(x1, x2, y_at, h=bridge_w) {
  xmid = (x1 + x2)/2;
  w = abs(x2 - x1) + overlap*2;
  translate([xmid, y_at]) square([max(0, w), h], center=true);
}

module tabs_2d() {
  union() {
    x_right = strap_L/2 - bridge_w/2 - overlap;
    bridge_between_2d(strapA_y(), strapB_y(), x_right, bridge_w);

    x_left = -strap_L/2 + bridge_w/2 + overlap;
    bridge_between_2d(strapB_y(), railB_y(), x_left, bridge_w);

    y_tab = railA_y() - rail_W/2 + bridge_w/2 - overlap;
    bridge_horizontal_2d(-rail_L/2, spool_x(), y_tab, bridge_w);
  }
}

// ---------------- Final Assembly (2D) ----------------
// Simplified: single top-level difference (avoids nested boolean complexity)
module assembly_2d() {
  difference() {
    union() {
      straps_2d();
      rails_2d();
      spool_2d();
      tabs_2d();
    }
    union() {
      strap_holes_all_2d();
      rail_notches_all_2d();
    }
  }
}

linear_extrude(height=t, center=true, convexity=5)
  assembly_2d();