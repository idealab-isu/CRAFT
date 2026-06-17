// Parameters
body_length = 3.0; //[1.5:6.0:0.1]
body_width = 1.8; //[0.9:3.6:0.1]
body_height = 0.9; //[0.45:1.8:0.05]
pad_length = 0.6; //[0.3:1.2:0.05]
pad_width = 1.4; //[0.7:2.0:0.05]
pad_thickness = 0.12; //[0.05:0.3:0.01]
pad_overlap = 0.8; //[0.5:1.5:0.05]
mark_radius = 0.25; //[0.12:0.5:0.01]
mark_depth = 0.08; //[0.03:0.2:0.01]
mark_edge_margin = 0.35; //[0.2:0.7:0.05]
chamfer_size = 0.2; //[0.1:0.5:0.05]
connect_overlap = 0.8; //[0.5:2.0:0.1]

// Base shapes
module smd_body() {
  color("DimGray")
  cube([body_length, body_width, body_height], center=true);
}

module terminal_pad_left() {
  translate([-body_length/2 - pad_length/2 + pad_overlap/2, 0, -body_height/2 + pad_thickness/2 - connect_overlap/2])
  color("Silver")
  cube([pad_length + pad_overlap, pad_width, pad_thickness], center=true);
}

module terminal_pad_right() {
  translate([body_length/2 + pad_length/2 - pad_overlap/2, 0, -body_height/2 + pad_thickness/2 - connect_overlap/2])
  color("Silver")
  cube([pad_length + pad_overlap, pad_width, pad_thickness], center=true);
}

module polarity_mark_cutter() {
  translate([-body_length/2 + mark_edge_margin, body_width/2 - mark_edge_margin, body_height/2 - mark_depth/2])
  cylinder(r=mark_radius, h=mark_depth + connect_overlap, center=true);
}

module chamfer_cutter_xpos() {
  translate([body_length/2 - chamfer_size/2, 0, 0])
  rotate([0, 45, 0])
  cube([chamfer_size, body_width + connect_overlap, body_height + connect_overlap], center=true);
}

module chamfer_cutter_xneg() {
  translate([-body_length/2 + chamfer_size/2, 0, 0])
  rotate([0, 45, 0])
  cube([chamfer_size, body_width + connect_overlap, body_height + connect_overlap], center=true);
}

module chamfer_cutter_ypos() {
  translate([0, body_width/2 - chamfer_size/2, 0])
  rotate([45, 0, 0])
  cube([body_length + connect_overlap, chamfer_size, body_height + connect_overlap], center=true);
}

module chamfer_cutter_yneg() {
  translate([0, -body_width/2 + chamfer_size/2, 0])
  rotate([45, 0, 0])
  cube([body_length + connect_overlap, chamfer_size, body_height + connect_overlap], center=true);
}

// Operations
module terminal_pads() {
  union() {
    terminal_pad_left();
    terminal_pad_right();
  }
}

module edge_chamfers() {
  difference() {
    smd_body();
    chamfer_cutter_xpos();
    chamfer_cutter_xneg();
    chamfer_cutter_ypos();
    chamfer_cutter_yneg();
  }
}

module polarity_mark() {
  difference() {
    edge_chamfers();
    polarity_mark_cutter();
  }
}

module smd_complete() {
  union() {
    polarity_mark();
    terminal_pads();
  }
}

// Final output
smd_complete();