// Parameters
sheet_length = 600; //[300:1200:1]
sheet_width = 400; //[200:800:1]
sheet_thickness = 18; //[9:36:1]
corner_radius = 10; //[2:30:1]
edge_chamfer = 1.5; //[0.5:4:0.5]
minkowski_sphere_radius = 0.75; //[0.25:2:0.25]

// Base shapes
module mdf_sheet() {
  cube([sheet_length, sheet_width, sheet_thickness], center=true);
}

module corner_cylinder() {
  cylinder(r=corner_radius, h=sheet_thickness + 2, center=true);
}

module edge_chamfer_sphere() {
  sphere(r=minkowski_sphere_radius, center=true);
}

// Operations
module rounded_corners_sheet() {
  hull() {
    translate([-sheet_length/2 + corner_radius, sheet_width/2 - corner_radius, 0]) corner_cylinder();
    translate([sheet_length/2 - corner_radius, sheet_width/2 - corner_radius, 0]) corner_cylinder();
    translate([-sheet_length/2 + corner_radius, -sheet_width/2 + corner_radius, 0]) corner_cylinder();
    translate([sheet_length/2 - corner_radius, -sheet_width/2 + corner_radius, 0]) corner_cylinder();
  }
}

module sheet_with_edge_chamfer() {
  minkowski() {
    rounded_corners_sheet();
    edge_chamfer_sphere();
  }
}

// Final model
module final_model() {
  union() {
    sheet_with_edge_chamfer();
    // Label text is not included as per rules
  }
}

// Render the final model
color([0.85, 0.85, 0.8]) // MDF color
final_model();