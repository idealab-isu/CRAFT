// Parameters
sheet_length = 200; //[100:400:1]
sheet_width = 150; //[75:300:1]
sheet_thickness = 2; //[1:6:0.5]
corner_radius = 10; //[5:20:1]
hole_diameter = 6; //[3:12:0.5]
hole_edge_margin = 15; //[8:30:1]
chamfer_size = 0.8; //[0.2:2:0.1]
overlap = 1; //[0.5:2:0.1]

// Base Shapes
module sheet_body() {
  translate([0, 0, sheet_thickness / 2])
    cube([sheet_length, sheet_width, sheet_thickness], center = true);
}

module rounded_corners() {
  linear_extrude(height = sheet_thickness, center = true) {
    offset(r = corner_radius) {
      polygon(points = [
        [-sheet_length / 2 + corner_radius, -sheet_width / 2],
        [sheet_length / 2 - corner_radius, -sheet_width / 2],
        [sheet_length / 2, -sheet_width / 2 + corner_radius],
        [sheet_length / 2, sheet_width / 2 - corner_radius],
        [sheet_length / 2 - corner_radius, sheet_width / 2],
        [-sheet_length / 2 + corner_radius, sheet_width / 2],
        [-sheet_length / 2, sheet_width / 2 - corner_radius],
        [-sheet_length / 2, -sheet_width / 2 + corner_radius]
      ]);
    }
  }
}

module mounting_hole(position) {
  translate(position)
    cylinder(r = hole_diameter / 2, h = sheet_thickness + 2 * overlap, center = true);
}

module chamfer_edges() {
  sphere(r = chamfer_size, center = true);
}

// Operations
module sheet_rounded_union() {
  union() {
    sheet_body();
    rounded_corners();
  }
}

module sheet_with_holes() {
  difference() {
    sheet_rounded_union();
    mounting_hole([-sheet_length / 2 + hole_edge_margin, -sheet_width / 2 + hole_edge_margin, 0]);
    mounting_hole([sheet_length / 2 - hole_edge_margin, -sheet_width / 2 + hole_edge_margin, 0]);
    mounting_hole([sheet_length / 2 - hole_edge_margin, sheet_width / 2 - hole_edge_margin, 0]);
    mounting_hole([-sheet_length / 2 + hole_edge_margin, sheet_width / 2 - hole_edge_margin, 0]);
  }
}

// Final Output
minkowski() {
  sheet_with_holes();
  chamfer_edges();
}