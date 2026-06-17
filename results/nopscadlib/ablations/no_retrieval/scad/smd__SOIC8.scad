// Parameters
body_length = 4.9; //[2.45:9.8:0.05]
body_width = 3.9; //[1.95:7.8:0.05]
body_height = 1.25; //[0.6:2.5:0.05]
pad_thickness = 0.08; //[0.04:0.2:0.01]
pad_inset = 0.25; //[0.1:0.8:0.05]
pad_overlap = 0.6; //[0.2:1.2:0.05]
pin1_mark_radius = 0.35; //[0.15:0.8:0.05]
pin1_mark_depth = 0.15; //[0.05:0.4:0.05]
pin1_edge_offset = 0.6; //[0.3:1.2:0.05]
top_chamfer = 0.25; //[0.1:0.6:0.05]
fillet_radius = 0.2; //[0.05:0.6:0.05]
fillet_shrink = 0.4; //[0.2:0.9:0.05]

// Base shapes
module smd_body_base() {
  translate([0, 0, 0])
    cube([body_length - 2*fillet_radius*fillet_shrink, 
          body_width - 2*fillet_radius*fillet_shrink, 
          body_height - 2*fillet_radius*fillet_shrink], center=true);
}

module body_fillet_kernel() {
  translate([0, 0, 0])
    sphere(r=fillet_radius, center=true);
}

module top_chamfer_wedge_x_pos() {
  translate([body_length/2 - top_chamfer/2, 0, body_height/2 - top_chamfer/2])
    cube([top_chamfer, body_width + 2*top_chamfer, top_chamfer], center=true);
}

module top_chamfer_wedge_x_neg() {
  translate([-body_length/2 + top_chamfer/2, 0, body_height/2 - top_chamfer/2])
    cube([top_chamfer, body_width + 2*top_chamfer, top_chamfer], center=true);
}

module top_chamfer_wedge_y_pos() {
  translate([0, body_width/2 - top_chamfer/2, body_height/2 - top_chamfer/2])
    cube([body_length + 2*top_chamfer, top_chamfer, top_chamfer], center=true);
}

module top_chamfer_wedge_y_neg() {
  translate([0, -body_width/2 + top_chamfer/2, body_height/2 - top_chamfer/2])
    cube([body_length + 2*top_chamfer, top_chamfer, top_chamfer], center=true);
}

module pin1_mark_cutter() {
  translate([-body_length/2 + pin1_edge_offset, body_width/2 - pin1_edge_offset, body_height/2 - pin1_mark_depth/2])
    cylinder(r=pin1_mark_radius, h=pin1_mark_depth, center=true);
}

module pad_left() {
  translate([-(body_length/2) + (body_length/2 - pad_inset + pad_overlap)/2, 0, -body_height/2 + pad_thickness/2])
    cube([body_length/2 - pad_inset + pad_overlap, body_width - 2*pad_inset, pad_thickness], center=true);
}

module pad_right() {
  translate([(body_length/2) - (body_length/2 - pad_inset + pad_overlap)/2, 0, -body_height/2 + pad_thickness/2])
    cube([body_length/2 - pad_inset + pad_overlap, body_width - 2*pad_inset, pad_thickness], center=true);
}

// Operations
module body_fillet() {
  minkowski() {
    smd_body_base();
    body_fillet_kernel();
  }
}

module top_chamfer_cutters() {
  union() {
    top_chamfer_wedge_x_pos();
    top_chamfer_wedge_x_neg();
    top_chamfer_wedge_y_pos();
    top_chamfer_wedge_y_neg();
  }
}

module smd_body_chamfered() {
  difference() {
    body_fillet();
    top_chamfer_cutters();
  }
}

module pin1_mark() {
  difference() {
    smd_body_chamfered();
    pin1_mark_cutter();
  }
}

module pads() {
  union() {
    pad_left();
    pad_right();
  }
}

module complete_model() {
  union() {
    pin1_mark();
    pads();
  }
}

// Final output
complete_model();