// Parameters
sheet_length = 300; //[150:600:1]
sheet_width = 200; //[100:400:1]
sheet_thickness = 2; //[1:6:0.5]
corner_radius = 10; //[2:25:1]
chamfer_size = 0.8; //[0.2:2:0.1]
op_overlap = 1; //[0.5:2:0.1]
texture_depth = 0; //[0:0.5:0.05]

// Base Shapes
module sheet_plate() {
  cube([sheet_length, sheet_width, sheet_thickness], center=true);
}

module rounded_corners_core() {
  cube([sheet_length - 2*corner_radius, sheet_width - 2*corner_radius, sheet_thickness], center=true);
}

module rounded_corners_cyl(pos) {
  translate(pos)
    cylinder(r=corner_radius, h=sheet_thickness, center=true);
}

module chamfer_edges_top_cut() {
  cube([sheet_length + 2*op_overlap, sheet_width + 2*op_overlap, chamfer_size], center=true);
}

module chamfer_edges_top_keep() {
  cube([sheet_length - 2*chamfer_size, sheet_width - 2*chamfer_size, chamfer_size + 2*op_overlap], center=true);
}

module chamfer_edges_bottom_cut() {
  cube([sheet_length + 2*op_overlap, sheet_width + 2*op_overlap, chamfer_size], center=true);
}

module chamfer_edges_bottom_keep() {
  cube([sheet_length - 2*chamfer_size, sheet_width - 2*chamfer_size, chamfer_size + 2*op_overlap], center=true);
}

module surface_texture_weave() {
  cube([sheet_length, sheet_width, texture_depth], center=true);
}

// Operations
module rounded_corners() {
  union() {
    rounded_corners_core();
    rounded_corners_cyl([sheet_length/2 - corner_radius, sheet_width/2 - corner_radius, 0]);
    rounded_corners_cyl([-sheet_length/2 + corner_radius, sheet_width/2 - corner_radius, 0]);
    rounded_corners_cyl([-sheet_length/2 + corner_radius, -sheet_width/2 + corner_radius, 0]);
    rounded_corners_cyl([sheet_length/2 - corner_radius, -sheet_width/2 + corner_radius, 0]);
  }
}

module chamfer_edges_top_ring() {
  difference() {
    chamfer_edges_top_cut();
    chamfer_edges_top_keep();
  }
}

module chamfer_edges_bottom_ring() {
  difference() {
    chamfer_edges_bottom_cut();
    chamfer_edges_bottom_keep();
  }
}

module chamfer_edges() {
  union() {
    chamfer_edges_top_ring();
    chamfer_edges_bottom_ring();
  }
}

module sheet_with_rounded_corners() {
  intersection() {
    sheet_plate();
    rounded_corners();
  }
}

module sheet_with_rounded_and_chamfered() {
  difference() {
    sheet_with_rounded_corners();
    chamfer_edges();
  }
}

// Final Output
module complete_model() {
  union() {
    sheet_with_rounded_and_chamfered();
    surface_texture_weave();
  }
}

// Render the complete model
color([0.15, 0.15, 0.15]) complete_model();