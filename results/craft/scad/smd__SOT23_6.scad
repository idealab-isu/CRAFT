// Parameters
body_L = 3.0; //[1.5:6.0:0.05]
body_W = 1.6; //[0.8:3.2:0.05]
body_H = 1.05; //[0.5:2.1:0.05]
term_L = 0.35; //[0.15:0.8:0.01]
term_H = 0.25; //[0.1:0.6:0.01]
term_inset = 0.05; //[0.0:0.2:0.01]
overlap = 0.8; //[0.3:1.5:0.05]
edge_fillet_r = 0.12; //[0.05:0.3:0.01]
chamfer = 0.18; //[0.05:0.4:0.01]
mark_L = 1.2; //[0.5:2.4:0.05]
mark_W = 0.5; //[0.2:1.2:0.05]
mark_depth = 0.05; //[0.01:0.15:0.01]

// Base shapes
module chip_body() {
  cube([body_L, body_W, body_H], center=true);
}

module terminal_end_1() {
  translate([-body_L/2 + (term_L + term_inset + overlap)/2 - overlap, 0, -body_H/2 + term_H/2])
    cube([term_L + term_inset + overlap, body_W, term_H], center=true);
}

module terminal_end_2() {
  translate([body_L/2 - (term_L + term_inset + overlap)/2 + overlap, 0, -body_H/2 + term_H/2])
    cube([term_L + term_inset + overlap, body_W, term_H], center=true);
}

module top_marking() {
  translate([-body_L/2 + mark_L/2 + overlap, 0, body_H/2 - mark_depth/2])
    cube([mark_L, mark_W, mark_depth], center=true);
}

module edge_fillet_sphere() {
  sphere(r=edge_fillet_r, center=true);
}

module chamfer_wedge() {
  rotate([0, 0, 45])
    cube([chamfer, chamfer, body_H + 2*overlap], center=true);
}

// Operations
module chip_body_with_terminals() {
  union() {
    chip_body();
    terminal_end_1();
    terminal_end_2();
  }
}

module chamfered_corners() {
  union() {
    translate([body_L/2 - chamfer/2, body_W/2 - chamfer/2, 0]) chamfer_wedge();
    translate([body_L/2 - chamfer/2, -body_W/2 + chamfer/2, 0]) chamfer_wedge();
    translate([-body_L/2 + chamfer/2, body_W/2 - chamfer/2, 0]) chamfer_wedge();
    translate([-body_L/2 + chamfer/2, -body_W/2 + chamfer/2, 0]) chamfer_wedge();
  }
}

module chip_body_chamfered() {
  difference() {
    chip_body_with_terminals();
    chamfered_corners();
  }
}

module chip_body_marked() {
  difference() {
    chip_body_chamfered();
    top_marking();
  }
}

module edge_fillet() {
  minkowski() {
    chip_body_marked();
    edge_fillet_sphere();
  }
}

// Final output
edge_fillet();