// Parameters
body_L = 11.4; //[5.7:22.8:0.1]
body_W = 7.5; //[3.75:15:0.1]
body_H = 2; //[1:4:0.05]
overlap = 0.8; //[0.5:2:0.1]
chamfer = 0.6; //[0.2:1.2:0.05]
pin_mark_r = 0.5; //[0.25:1:0.05]
pin_mark_depth = 0.25; //[0.1:0.6:0.05]
pin_mark_inset = 1.2; //[0.6:2.4:0.1]
top_mark_L = 6.5; //[3.25:13:0.1]
top_mark_W = 3.0; //[1.5:6:0.1]
top_mark_depth = 0.15; //[0.05:0.4:0.05]

// Base Shapes
module smd_body() {
  color("DimGray")
  translate([0, 0, 0])
    cube([body_L, body_W, body_H], center=true);
}

module pin_mark() {
  color("Black")
  translate([-body_L/2 + pin_mark_inset, body_W/2 - pin_mark_inset, body_H/2 - pin_mark_depth/2])
    cylinder(r=pin_mark_r, h=pin_mark_depth + overlap, center=true);
}

module top_marking() {
  color("Black")
  translate([0, 0, body_H/2 - top_mark_depth/2])
    cube([top_mark_L, top_mark_W, top_mark_depth + overlap], center=true);
}

module edge_chamfer() {
  color("Black")
  translate([body_L/2 - chamfer/2, 0, 0])
    rotate([0, 0, 45])
      cube([chamfer, body_W + 2*overlap, body_H + 2*overlap], center=true);
}

// Operations
module final_model() {
  difference() {
    smd_body();
    pin_mark();
    top_marking();
    edge_chamfer();
  }
}

// Final Output
final_model();