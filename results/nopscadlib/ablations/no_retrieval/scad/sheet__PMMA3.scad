// Parameters
sheet_length = 200; //[100:400:1]
sheet_width = 150; //[75:300:1]
sheet_thickness = 2; //[1:6:0.5]
corner_radius = 12; //[6:24:1]
hole_diameter = 6; //[3:12:0.5]
hole_edge_margin = 15; //[8:30:1]
chamfer_size = 0.8; //[0.2:2:0.1]
chamfer_depth = 0.4; //[0.1:1.5:0.1]
eps_overlap = 1; //[0.5:2:0.1]

// Base shapes
module sheet_body_rect() {
  cube([sheet_length - 2*corner_radius, sheet_width, sheet_thickness], center=true);
}

module sheet_body_rect2() {
  cube([sheet_length, sheet_width - 2*corner_radius, sheet_thickness], center=true);
}

module rounded_corner_cyl(pos) {
  translate(pos)
    cylinder(r=corner_radius, h=sheet_thickness, center=true);
}

module mounting_hole(pos) {
  translate(pos)
    cylinder(r=hole_diameter/2, h=sheet_thickness + 2*eps_overlap, center=true);
}

module chamfer_outer_plate() {
  cube([sheet_length + 2*eps_overlap, sheet_width + 2*eps_overlap, chamfer_depth + eps_overlap], center=true);
}

module chamfer_inner_plate() {
  cube([sheet_length - 2*chamfer_size, sheet_width - 2*chamfer_size, chamfer_depth + 2*eps_overlap], center=true);
}

// Operations
module rounded_corners() {
  union() {
    sheet_body_rect();
    sheet_body_rect2();
    rounded_corner_cyl([sheet_length/2 - corner_radius, sheet_width/2 - corner_radius, 0]);
    rounded_corner_cyl([-sheet_length/2 + corner_radius, sheet_width/2 - corner_radius, 0]);
    rounded_corner_cyl([-sheet_length/2 + corner_radius, -sheet_width/2 + corner_radius, 0]);
    rounded_corner_cyl([sheet_length/2 - corner_radius, -sheet_width/2 + corner_radius, 0]);
  }
}

module mounting_holes() {
  union() {
    mounting_hole([sheet_length/2 - hole_edge_margin, sheet_width/2 - hole_edge_margin, 0]);
    mounting_hole([-sheet_length/2 + hole_edge_margin, sheet_width/2 - hole_edge_margin, 0]);
    mounting_hole([-sheet_length/2 + hole_edge_margin, -sheet_width/2 + hole_edge_margin, 0]);
    mounting_hole([sheet_length/2 - hole_edge_margin, -sheet_width/2 + hole_edge_margin, 0]);
  }
}

module chamfer_edges() {
  difference() {
    chamfer_outer_plate();
    chamfer_inner_plate();
  }
}

module sheet_minus_holes() {
  difference() {
    rounded_corners();
    mounting_holes();
  }
}

module sheet_minus_holes_minus_chamfer() {
  difference() {
    sheet_minus_holes();
    chamfer_edges();
  }
}

module final_model() {
  difference() {
    sheet_minus_holes_minus_chamfer();
    // Engraved label is ignored as per rules
  }
}

// Final output
color("Silver") final_model();