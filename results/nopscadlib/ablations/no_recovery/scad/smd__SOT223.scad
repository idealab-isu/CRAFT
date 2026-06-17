// Parameters
body_L = 6.5; //[3.25:13:0.1]
body_W = 3.5; //[1.75:7:0.1]
body_H = 1.6; //[0.8:3.2:0.05]
chamfer = 0.25; //[0.1:0.6:0.05]
mark_depth = 0.08; //[0.03:0.2:0.01]
polarity_r = 0.35; //[0.15:0.8:0.05]
top_mark_L = 2.2; //[1:4.4:0.1]
top_mark_W = 1.2; //[0.6:2.4:0.1]
pad_recess_depth = 0.06; //[0.02:0.2:0.01]
pad_L = 1.2; //[0.6:2.4:0.1]
pad_W = 2.6; //[1.3:3.4:0.1]
pad_edge_margin = 0.25; //[0.1:0.8:0.05]

// Base shapes
module smd_body() {
  cube([body_L, body_W, body_H], center=true);
}

module edge_chamfer() {
  sphere(r=chamfer, center=true);
}

module polarity_mark() {
  translate([body_L/2 - polarity_r - chamfer, body_W/2 - polarity_r - chamfer, body_H/2 - mark_depth/2])
    cylinder(r=polarity_r, h=mark_depth, center=true);
}

module top_marking() {
  translate([0, 0, body_H/2 - mark_depth/2])
    cube([top_mark_L, top_mark_W, mark_depth], center=true);
}

module terminal_pad_left() {
  translate([-body_L/2 + pad_edge_margin + pad_L/2, 0, -body_H/2 + pad_recess_depth/2])
    cube([pad_L, pad_W, pad_recess_depth], center=true);
}

module terminal_pad_right() {
  translate([body_L/2 - pad_edge_margin - pad_L/2, 0, -body_H/2 + pad_recess_depth/2])
    cube([pad_L, pad_W, pad_recess_depth], center=true);
}

// Operations
module body_with_edge_chamfer() {
  minkowski() {
    smd_body();
    edge_chamfer();
  }
}

module terminal_pads() {
  union() {
    terminal_pad_left();
    terminal_pad_right();
  }
}

module body_minus_pads() {
  difference() {
    body_with_edge_chamfer();
    terminal_pads();
  }
}

module body_minus_pads_and_marks() {
  difference() {
    body_minus_pads();
    polarity_mark();
    top_marking();
  }
}

// Final output
body_minus_pads_and_marks();