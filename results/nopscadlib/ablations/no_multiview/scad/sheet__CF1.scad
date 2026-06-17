// Parameters
sheet_length = 300; //[150:600:1]
sheet_width = 200; //[100:400:1]
sheet_thickness = 2; //[1:6:0.5]
chamfer_size = 0.5; //[0.2:2:0.1]
corner_radius = 2; //[0.5:10:0.5]
texture_depth = 0.1; //[0:0.5:0.05]
label_depth = 0.2; //[0:1:0.05]
label_length = 40; //[20:120:1]
label_width = 15; //[8:60:1]
label_margin = 10; //[5:40:1]
eps_overlap = 0.5; //[0.1:2:0.1]

// Base Shapes
module sheet_plate() {
  cube([sheet_length, sheet_width, sheet_thickness], center=true);
}

module rounded_corners() {
  sphere(r=corner_radius, center=true);
}

module edge_chamfer() {
  sphere(r=chamfer_size, center=true);
}

module weave_texture() {
  translate([0, 0, sheet_thickness/2 - texture_depth/2 + eps_overlap])
    cube([sheet_length - 2*label_margin, sheet_width - 2*label_margin, texture_depth], center=true);
}

module engraved_label() {
  translate([-sheet_length/2 + label_margin + label_length/2, 
             -sheet_width/2 + label_margin + label_width/2, 
             sheet_thickness/2 - (label_depth + eps_overlap)/2])
    cube([label_length, label_width, label_depth + eps_overlap], center=true);
}

// Operations
module op_round_corners_minkowski() {
  minkowski() {
    sheet_plate();
    rounded_corners();
  }
}

module op_edge_chamfer_minkowski() {
  minkowski() {
    op_round_corners_minkowski();
    edge_chamfer();
  }
}

module op_add_weave_texture_union() {
  union() {
    op_edge_chamfer_minkowski();
    weave_texture();
  }
}

module op_engrave_label_difference() {
  difference() {
    op_add_weave_texture_union();
    engraved_label();
  }
}

// Final Output
color([0.2, 0.2, 0.2]) // Carbon-fiber look
op_engrave_label_difference();