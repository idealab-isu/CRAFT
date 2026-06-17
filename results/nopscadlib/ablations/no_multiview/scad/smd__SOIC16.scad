// Parameters
body_length = 9.9; //[5:20:0.1]
body_width = 3.9; //[2:8:0.1]
body_height = 1.25; //[0.6:2.5:0.05]
edge_chamfer_size = 0.35; //[0.15:0.8:0.05]
pin_mark_radius = 0.35; //[0.15:0.8:0.05]
pin_mark_depth = 0.15; //[0.05:0.4:0.05]
pin_mark_inset_x = 0.9; //[0.4:2:0.1]
pin_mark_inset_y = 0.8; //[0.4:2:0.1]
top_mark_length = 6.5; //[3:12:0.1]
top_mark_width = 1.2; //[0.5:3:0.1]
top_mark_depth = 0.08; //[0.03:0.25:0.01]
overlap = 0.8; //[0.5:2:0.1]

// Base shapes
module smd_body() {
  color("DimGray")
  cube([body_length, body_width, body_height], center=true);
}

module pin_mark() {
  translate([-body_length/2 + pin_mark_inset_x, -body_width/2 + pin_mark_inset_y, body_height/2 - pin_mark_depth/2])
  cylinder(h=pin_mark_depth + overlap, r=pin_mark_radius, center=true);
}

module top_marking() {
  translate([0, 0, body_height/2 - top_mark_depth/2])
  cube([top_mark_length, top_mark_width, top_mark_depth + overlap], center=true);
}

module edge_chamfer_x_pos() {
  translate([body_length/2 - edge_chamfer_size/2, 0, body_height/2 - edge_chamfer_size/2])
  rotate([0, 45, 0])
  cube([edge_chamfer_size, body_width + overlap, edge_chamfer_size], center=true);
}

module edge_chamfer_x_neg() {
  translate([-body_length/2 + edge_chamfer_size/2, 0, body_height/2 - edge_chamfer_size/2])
  rotate([0, 45, 0])
  cube([edge_chamfer_size, body_width + overlap, edge_chamfer_size], center=true);
}

module edge_chamfer_y_pos() {
  translate([0, body_width/2 - edge_chamfer_size/2, body_height/2 - edge_chamfer_size/2])
  rotate([45, 0, 0])
  cube([body_length + overlap, edge_chamfer_size, edge_chamfer_size], center=true);
}

module edge_chamfer_y_neg() {
  translate([0, -body_width/2 + edge_chamfer_size/2, body_height/2 - edge_chamfer_size/2])
  rotate([45, 0, 0])
  cube([body_length + overlap, edge_chamfer_size, edge_chamfer_size], center=true);
}

// Operations
module edge_chamfer() {
  union() {
    edge_chamfer_x_pos();
    edge_chamfer_x_neg();
    edge_chamfer_y_pos();
    edge_chamfer_y_neg();
  }
}

module smd_with_features() {
  difference() {
    smd_body();
    edge_chamfer();
    pin_mark();
    top_marking();
  }
}

// Final output
smd_with_features();