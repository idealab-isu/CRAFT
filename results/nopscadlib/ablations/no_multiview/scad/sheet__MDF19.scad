// Parameters
sheet_length = 200; //[100:400:1]
sheet_width = 150; //[75:300:1]
sheet_thickness = 3; //[1.5:6:0.5]
corner_radius = 12; //[6:24:1]
hole_diameter = 6; //[3:12:0.5]
hole_edge_offset = 15; //[8:30:1]
chamfer_size = 1; //[0.5:3:0.25]
connect_overlap = 1; //[0.5:2:0.1]

// Base Shapes
module sheet_body() {
  translate([0, 0, sheet_thickness / 2])
    cube([sheet_length, sheet_width, sheet_thickness], center = true);
}

module rounded_corner() {
  translate([sheet_length / 2 - corner_radius, sheet_width / 2 - corner_radius, 0])
    cylinder(r = corner_radius, h = sheet_thickness + 2 * connect_overlap, center = true);
}

module mounting_hole(x, y) {
  translate([x, y, 0])
    cylinder(r = hole_diameter / 2, h = sheet_thickness + 2 * connect_overlap, center = true);
}

module chamfer_kernel_sphere() {
  sphere(r = chamfer_size, center = true);
}

// Operations
module rounded_corners_union() {
  union() {
    rounded_corner();
    mirror([1, 0, 0]) rounded_corner();
    mirror([0, 1, 0]) rounded_corner();
    mirror([1, 1, 0]) rounded_corner();
  }
}

module sheet_with_rounded_corners() {
  minkowski() {
    sheet_body();
    chamfer_kernel_sphere();
  }
}

module mounting_holes() {
  union() {
    mounting_hole(sheet_length / 2 - hole_edge_offset, sheet_width / 2 - hole_edge_offset);
    mounting_hole(-sheet_length / 2 + hole_edge_offset, sheet_width / 2 - hole_edge_offset);
    mounting_hole(-sheet_length / 2 + hole_edge_offset, -sheet_width / 2 + hole_edge_offset);
    mounting_hole(sheet_length / 2 - hole_edge_offset, -sheet_width / 2 + hole_edge_offset);
  }
}

module sheet_minus_holes() {
  difference() {
    sheet_with_rounded_corners();
    mounting_holes();
  }
}

module chamfer_edges() {
  union() {
    sheet_minus_holes();
    rounded_corners_union();
  }
}

// Final Output
color("Silver") chamfer_edges();