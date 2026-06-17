// Parameters
across_flats = 10.0; //[5.0:20.0:0.1]
thickness = 3.2; //[1.6:6.4:0.1]
hole_diameter = 6.2; //[3.0:12.0:0.1]
chamfer_size = 0.3; //[0.1:1.0:0.05]
corner_round_radius = 0.2; //[0.0:0.8:0.05]
overlap = 0.8; //[0.5:2.0:0.1]
hex_circumradius = 5.7735; //[2.8867:11.547:0.0001]
hole_radius = 3.1; //[1.5:6.0:0.0001]

// Hexagonal Nut Body
module hex_nut_body() {
  linear_extrude(height = thickness, center = true) {
    polygon(points = [
      [hex_circumradius, 0],
      [hex_circumradius / 2, hex_circumradius * 0.866025403784],
      [-hex_circumradius / 2, hex_circumradius * 0.866025403784],
      [-hex_circumradius, 0],
      [-hex_circumradius / 2, -hex_circumradius * 0.866025403784],
      [hex_circumradius / 2, -hex_circumradius * 0.866025403784]
    ]);
  }
}

// Center Through Hole
module center_through_hole() {
  translate([0, 0, 0])
    cylinder(r = hole_radius, h = thickness + 2 * overlap, center = true);
}

// Top Edge Chamfer
module top_edge_chamfer() {
  translate([0, 0, thickness / 2 - chamfer_size / 2 + overlap / 2])
    cylinder(r1 = hex_circumradius + overlap, r2 = 0, h = chamfer_size, center = true);
}

// Bottom Edge Chamfer
module bottom_edge_chamfer() {
  translate([0, 0, -thickness / 2 + chamfer_size / 2 - overlap / 2])
    cylinder(r1 = hex_circumradius + overlap, r2 = 0, h = chamfer_size, center = true);
}

// Corner Rounding
module corner_rounding() {
  translate([0, 0, 0])
    sphere(r = corner_round_radius, center = true);
}

// Thread Detail (No-op)
module thread_detail() {
  // Placeholder for thread detail, not implemented
}

// Surface Markings (No-op)
module surface_markings() {
  // Placeholder for surface markings, not implemented
}

// Complete Model
module complete_model() {
  difference() {
    minkowski() {
      hex_nut_body();
      corner_rounding();
    }
    center_through_hole();
    top_edge_chamfer();
    bottom_edge_chamfer();
  }
}

// Final Output
color("Silver") complete_model();