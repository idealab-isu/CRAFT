// Parameters
body_L = 3.0; //[1.5:6.0:0.05]
body_W = 1.6; //[0.8:3.2:0.05]
body_H = 1.05; //[0.5:2.1:0.05]
term_L = 0.35; //[0.15:0.7:0.01]
term_H = 0.55; //[0.25:1.1:0.01]
term_inset = 0.05; //[0.0:0.2:0.01]
overlap = 0.8; //[0.5:2.0:0.1]
mark_L = 1.2; //[0.6:2.4:0.05]
mark_W = 0.5; //[0.2:1.2:0.05]
mark_H = 0.03; //[0.01:0.1:0.01]
fillet_r = 0.12; //[0.05:0.3:0.01]
chamfer_L = 0.12; //[0.05:0.3:0.01]

// Base shapes
module chip_body_base() {
  cube([body_L - 2*fillet_r, body_W - 2*fillet_r, body_H - 2*fillet_r], center=true);
}

module fillet_sphere() {
  sphere(r=fillet_r, center=true);
}

module terminal_block() {
  cube([term_L + overlap, body_W, term_H], center=true);
}

module chamfer_cutter() {
  rotate([0, 45, 0])
    cube([chamfer_L, body_W + 2*overlap, term_H + 2*overlap], center=true);
}

module top_marking() {
  cube([mark_L, mark_W, mark_H], center=true);
}

// Operations
module chip_body_fillet() {
  minkowski() {
    chip_body_base();
    fillet_sphere();
  }
}

module terminal_left_pos() {
  translate([-(body_L/2 - term_inset - (term_L + overlap)/2), 0, -body_H/2 + term_H/2])
    terminal_block();
}

module terminal_right_pos() {
  translate([(body_L/2 - term_inset - (term_L + overlap)/2), 0, -body_H/2 + term_H/2])
    terminal_block();
}

module chamfer_left_pos() {
  translate([-(body_L/2 - term_inset - chamfer_L/2), 0, -body_H/2 + term_H/2])
    chamfer_cutter();
}

module chamfer_right_pos() {
  translate([(body_L/2 - term_inset - chamfer_L/2), 0, -body_H/2 + term_H/2])
    chamfer_cutter();
}

module terminal_left_chamfered() {
  difference() {
    terminal_left_pos();
    chamfer_left_pos();
  }
}

module terminal_right_chamfered() {
  difference() {
    terminal_right_pos();
    chamfer_right_pos();
  }
}

module end_terminals_2x() {
  union() {
    terminal_left_chamfered();
    terminal_right_chamfered();
  }
}

module smd_complete_model() {
  union() {
    chip_body_fillet();
    end_terminals_2x();
    translate([0, 0, body_H/2 + mark_H/2 - overlap])
      top_marking();
  }
}

// Final output
smd_complete_model();