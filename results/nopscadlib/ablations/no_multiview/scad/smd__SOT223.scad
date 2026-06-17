// Parameters
body_length = 6.5; //[3.25:13:0.1]
body_width = 3.5; //[1.75:7:0.1]
body_height = 1.6; //[0.8:3.2:0.05]
chamfer_size = 0.35; //[0.15:0.8:0.05]
pad_length = 0.9; //[0.4:1.8:0.05]
pad_thickness = 0.12; //[0.05:0.3:0.01]
pad_width_margin = 0.3; //[0.1:0.8:0.05]
pad_overlap = 0.8; //[0.5:1.5:0.05]
mark_radius = 0.35; //[0.15:0.8:0.05]
mark_height = 0.15; //[0.05:0.4:0.01]
mark_inset = 0.6; //[0.2:1.5:0.05]
top_marking_depth = 0.08; //[0.03:0.2:0.01]
top_marking_margin = 0.7; //[0.3:1.5:0.05]
eps = 0.8; //[0.2:2:0.1]

// Base shapes
module smd_body() {
  color([0.85, 0.85, 0.8])
  cube([body_length, body_width, body_height], center=true);
}

module edge_chamfer_wedge(x_pos, y_pos) {
  translate([x_pos, y_pos, 0])
  rotate([0, 0, 45])
  cube([chamfer_size, chamfer_size, body_height + 2*eps], center=true);
}

module terminal_pad(x_pos) {
  translate([x_pos, 0, -(body_height/2 + pad_thickness/2 - eps)])
  cube([pad_length, body_width - 2*pad_width_margin, pad_thickness], center=true);
}

module polarity_mark() {
  translate([-(body_length/2 - mark_inset), body_width/2 - mark_inset, body_height/2 + mark_height/2 - eps])
  cylinder(r=mark_radius, h=mark_height, center=true);
}

module top_marking() {
  translate([0, 0, body_height/2 - top_marking_depth/2 + eps])
  cube([body_length - 2*top_marking_margin, body_width - 2*top_marking_margin, top_marking_depth], center=true);
}

// Operations
module edge_chamfers() {
  union() {
    edge_chamfer_wedge(body_length/2 - chamfer_size/2, body_width/2 - chamfer_size/2);
    edge_chamfer_wedge(body_length/2 - chamfer_size/2, -(body_width/2 - chamfer_size/2));
    edge_chamfer_wedge(-(body_length/2 - chamfer_size/2), body_width/2 - chamfer_size/2);
    edge_chamfer_wedge(-(body_length/2 - chamfer_size/2), -(body_width/2 - chamfer_size/2));
  }
}

module body_with_edge_chamfers() {
  difference() {
    smd_body();
    edge_chamfers();
  }
}

module body_with_edge_chamfers_and_top_marking() {
  difference() {
    body_with_edge_chamfers();
    top_marking();
  }
}

module terminal_pads() {
  union() {
    terminal_pad(-(body_length/2 - pad_overlap - pad_length/2));
    terminal_pad(body_length/2 - pad_overlap - pad_length/2);
  }
}

// Final model
module smd_complete_model() {
  union() {
    body_with_edge_chamfers_and_top_marking();
    terminal_pads();
    polarity_mark();
  }
}

// Render the final model
smd_complete_model();