// Parameters
sheet_length = 300; //[150:600:1]
sheet_width = 200; //[100:400:1]
sheet_thickness = 2; //[1:6:0.5]
corner_radius = 10; //[2:30:1]
chamfer_size = 0.8; //[0.2:2:0.1]
overlap = 1; //[0.5:2:0.5]

// Base Shapes
module sheet_plate() {
  cube([sheet_length, sheet_width, sheet_thickness], center=true);
}

module rounded_corners() {
  linear_extrude(height=sheet_thickness, center=true) {
    polygon(points=[
      [-sheet_length/2 + corner_radius, -sheet_width/2],
      [sheet_length/2 - corner_radius, -sheet_width/2],
      [sheet_length/2, -sheet_width/2 + corner_radius],
      [sheet_length/2, sheet_width/2 - corner_radius],
      [sheet_length/2 - corner_radius, sheet_width/2],
      [-sheet_length/2 + corner_radius, sheet_width/2],
      [-sheet_length/2, sheet_width/2 - corner_radius],
      [-sheet_length/2, -sheet_width/2 + corner_radius]
    ]);
  }
}

module rounded_corners_corner_circle(pos) {
  translate(pos)
    cylinder(r=corner_radius, h=sheet_thickness, center=true);
}

module chamfer_edges_sphere() {
  sphere(r=chamfer_size);
}

module surface_texture_weave() {
  cube([sheet_length, sheet_width, sheet_thickness], center=true);
}

// Operations
module rounded_corners_union() {
  union() {
    rounded_corners();
    rounded_corners_corner_circle([sheet_length/2 - corner_radius, sheet_width/2 - corner_radius, 0]);
    rounded_corners_corner_circle([-sheet_length/2 + corner_radius, sheet_width/2 - corner_radius, 0]);
    rounded_corners_corner_circle([sheet_length/2 - corner_radius, -sheet_width/2 + corner_radius, 0]);
    rounded_corners_corner_circle([-sheet_length/2 + corner_radius, -sheet_width/2 + corner_radius, 0]);
  }
}

module sheet_with_rounded_corners() {
  intersection() {
    sheet_plate();
    rounded_corners_union();
  }
}

module chamfer_edges() {
  minkowski() {
    sheet_with_rounded_corners();
    chamfer_edges_sphere();
  }
}

module complete_model() {
  union() {
    chamfer_edges();
    surface_texture_weave();
  }
}

// Final Output
color([0.2, 0.2, 0.2]) complete_model();