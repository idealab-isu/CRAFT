// Parameters
sheet_length = 200; //[100:400:1]
sheet_width = 200; //[100:400:1]
sheet_thickness = 2; //[1:6:0.5]
corner_radius = 12; //[6:24:1]
hole_diameter = 6; //[3:12:0.5]
hole_edge_offset = 20; //[10:40:1]
chamfer_size = 1; //[0.5:3:0.25]
overlap = 1; //[0.5:2:0.5]

// Base shapes
module sheet_body() {
  cube([sheet_length, sheet_width, sheet_thickness], center=true);
}

module rounded_corners_base() {
  cube([sheet_length - 2*corner_radius, sheet_width - 2*corner_radius, sheet_thickness], center=true);
}

module rounded_corner_cyl(pos) {
  translate(pos)
    cylinder(r=corner_radius, h=sheet_thickness, center=true);
}

module mounting_hole(pos) {
  translate(pos)
    cylinder(r=hole_diameter/2, h=sheet_thickness + 2*overlap, center=true);
}

module chamfer_wedge_x(pos) {
  translate(pos)
    cube([chamfer_size, sheet_width + 2*overlap, sheet_thickness + 2*overlap], center=true);
}

module chamfer_wedge_y(pos) {
  translate(pos)
    cube([sheet_length + 2*overlap, chamfer_size, sheet_thickness + 2*overlap], center=true);
}

// Operations
module rounded_corners() {
  union() {
    rounded_corners_base();
    rounded_corner_cyl([sheet_length/2 - corner_radius, sheet_width/2 - corner_radius, 0]);
    rounded_corner_cyl([-sheet_length/2 + corner_radius, sheet_width/2 - corner_radius, 0]);
    rounded_corner_cyl([-sheet_length/2 + corner_radius, -sheet_width/2 + corner_radius, 0]);
    rounded_corner_cyl([sheet_length/2 - corner_radius, -sheet_width/2 + corner_radius, 0]);
  }
}

module mounting_holes() {
  union() {
    mounting_hole([sheet_length/2 - hole_edge_offset, sheet_width/2 - hole_edge_offset, 0]);
    mounting_hole([-sheet_length/2 + hole_edge_offset, sheet_width/2 - hole_edge_offset, 0]);
    mounting_hole([-sheet_length/2 + hole_edge_offset, -sheet_width/2 + hole_edge_offset, 0]);
    mounting_hole([sheet_length/2 - hole_edge_offset, -sheet_width/2 + hole_edge_offset, 0]);
  }
}

module chamfer_edges() {
  union() {
    chamfer_wedge_x([sheet_length/2 - chamfer_size/2, 0, 0]);
    chamfer_wedge_x([-sheet_length/2 + chamfer_size/2, 0, 0]);
    chamfer_wedge_y([0, sheet_width/2 - chamfer_size/2, 0]);
    chamfer_wedge_y([0, -sheet_width/2 + chamfer_size/2, 0]);
  }
}

// Final model
module complete_model() {
  difference() {
    intersection() {
      sheet_body();
      rounded_corners();
    }
    mounting_holes();
    chamfer_edges();
  }
}

// Render the final output
color("Silver") complete_model();