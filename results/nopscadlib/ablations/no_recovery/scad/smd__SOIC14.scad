// Parameters
body_L = 8.7; //[4.35:17.4:0.05]
body_W = 3.9; //[1.95:7.8:0.05]
body_H = 1.25; //[0.625:2.5:0.05]
term_L = 0.8; //[0.4:1.6:0.05]
term_thk = 0.08; //[0.04:0.2:0.01]
term_overlap = 0.6; //[0.3:1.2:0.05]
mark_L = 3.0; //[1.5:6.0:0.1]
mark_W = 1.6; //[0.8:3.2:0.1]
mark_depth = 0.05; //[0.02:0.15:0.01]
chamfer = 0.25; //[0.1:0.6:0.05]
fillet_r = 0.35; //[0.15:0.8:0.05]

// Base Shapes
module smd_body() {
  translate([0, 0, 0])
    cube([body_L, body_W, body_H], center=true);
}

module pin_term_left() {
  translate([-body_L/2 + (term_L + term_thk)/2 - term_overlap, 0, 0])
    cube([term_L + term_thk, body_W, body_H], center=true);
}

module pin_term_right() {
  translate([body_L/2 - (term_L + term_thk)/2 + term_overlap, 0, 0])
    cube([term_L + term_thk, body_W, body_H], center=true);
}

module top_marking_recess() {
  translate([0, 0, body_H/2 - mark_depth/2])
    cube([mark_L, mark_W, mark_depth], center=true);
}

module chamfer_wedge_xpos() {
  translate([body_L/2 - chamfer/2, 0, 0])
    rotate([0, 45, 0])
      cube([chamfer, body_W + 2*chamfer, body_H + 2*chamfer], center=true);
}

module chamfer_wedge_xneg() {
  translate([-body_L/2 + chamfer/2, 0, 0])
    rotate([0, 45, 0])
      cube([chamfer, body_W + 2*chamfer, body_H + 2*chamfer], center=true);
}

module chamfer_wedge_ypos() {
  translate([0, body_W/2 - chamfer/2, 0])
    rotate([45, 0, 0])
      cube([body_L + 2*chamfer, chamfer, body_H + 2*chamfer], center=true);
}

module chamfer_wedge_yneg() {
  translate([0, -body_W/2 + chamfer/2, 0])
    rotate([45, 0, 0])
      cube([body_L + 2*chamfer, chamfer, body_H + 2*chamfer], center=true);
}

module fillet_cyl_xpos_ypos() {
  translate([body_L/2 - fillet_r, body_W/2 - fillet_r, 0])
    cylinder(r=fillet_r, h=body_H + 2*fillet_r, center=true);
}

module fillet_cyl_xpos_yneg() {
  translate([body_L/2 - fillet_r, -body_W/2 + fillet_r, 0])
    cylinder(r=fillet_r, h=body_H + 2*fillet_r, center=true);
}

module fillet_cyl_xneg_ypos() {
  translate([-body_L/2 + fillet_r, body_W/2 - fillet_r, 0])
    cylinder(r=fillet_r, h=body_H + 2*fillet_r, center=true);
}

module fillet_cyl_xneg_yneg() {
  translate([-body_L/2 + fillet_r, -body_W/2 + fillet_r, 0])
    cylinder(r=fillet_r, h=body_H + 2*fillet_r, center=true);
}

// Operations
module pin_terminations() {
  union() {
    pin_term_left();
    pin_term_right();
  }
}

module edge_chamfers() {
  union() {
    chamfer_wedge_xpos();
    chamfer_wedge_xneg();
    chamfer_wedge_ypos();
    chamfer_wedge_yneg();
  }
}

module corner_fillets() {
  union() {
    fillet_cyl_xpos_ypos();
    fillet_cyl_xpos_yneg();
    fillet_cyl_xneg_ypos();
    fillet_cyl_xneg_yneg();
  }
}

module body_plus_terms() {
  union() {
    smd_body();
    pin_terminations();
  }
}

module body_with_chamfers() {
  difference() {
    body_plus_terms();
    edge_chamfers();
  }
}

module body_with_fillets() {
  difference() {
    body_with_chamfers();
    corner_fillets();
  }
}

module top_marking() {
  difference() {
    body_with_fillets();
    top_marking_recess();
  }
}

// Final Output
top_marking();