// Parameters
body_L = 3; //[1.5:6:0.1]
body_W = 1.4; //[0.7:2.8:0.1]
body_H = 1; //[0.5:2:0.1]
term_thk = 0.08; //[0.04:0.2:0.01]
term_len = 0.35; //[0.15:0.8:0.05]
term_overlap = 0.6; //[0.3:1.2:0.05]
chamfer = 0.12; //[0.05:0.3:0.01]
mark_depth = 0.05; //[0.02:0.15:0.01]
mark_margin = 0.25; //[0.1:0.6:0.05]
polarity_r = 0.18; //[0.08:0.4:0.01]
eps = 0.02; //[0.01:0.1:0.01]

// Base Shapes
module smd_body() {
  cube([body_L, body_W, body_H], center=true);
}

module metal_termination_left() {
  translate([-body_L/2 + (term_len + term_overlap)/2 - eps, 0, 0])
    cube([term_len + term_overlap, body_W + 2*term_thk, body_H + 2*term_thk], center=true);
}

module metal_termination_right() {
  translate([body_L/2 - (term_len + term_overlap)/2 + eps, 0, 0])
    cube([term_len + term_overlap, body_W + 2*term_thk, body_H + 2*term_thk], center=true);
}

module edge_chamfer_corner_cut() {
  cube([chamfer, chamfer, body_H + 2*eps], center=true);
}

module top_marking() {
  translate([0, 0, body_H/2 - (mark_depth + eps)/2 + eps])
    cube([body_L - 2*mark_margin, body_W - 2*mark_margin, mark_depth + eps], center=true);
}

module polarity_mark() {
  translate([-body_L/2 + mark_margin + polarity_r, body_W/2 - mark_margin - polarity_r, body_H/2 - (mark_depth + 2*eps)/2 + eps])
    cylinder(r=polarity_r, h=mark_depth + 2*eps, center=true);
}

// Operations
module metal_terminations() {
  union() {
    metal_termination_left();
    metal_termination_right();
  }
}

module edge_chamfer() {
  union() {
    edge_chamfer_corner_cut();
    rotate([0, 0, 90]) edge_chamfer_corner_cut();
    rotate([0, 0, 180]) edge_chamfer_corner_cut();
    rotate([0, 0, 270]) edge_chamfer_corner_cut();
  }
}

module smd_body_chamfered() {
  difference() {
    smd_body();
    edge_chamfer();
  }
}

module smd_body_marked() {
  difference() {
    smd_body_chamfered();
    top_marking();
    polarity_mark();
  }
}

module smd_complete() {
  union() {
    smd_body_marked();
    metal_terminations();
  }
}

// Final Output
smd_complete();