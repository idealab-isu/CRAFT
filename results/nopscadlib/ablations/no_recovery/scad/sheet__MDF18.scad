// Parameters
sheet_length = 2440; //[1220:4880:10]
sheet_width = 1220; //[610:2440:10]
sheet_thickness = 18; //[9:36:1]
corner_radius = 6; //[0:30:1]
edge_chamfer = 1; //[0:5:0.5]
overlap = 1; //[0.5:2:0.5]

// Base Shapes
module mdf_sheet_body() {
  cube([sheet_length, sheet_width, sheet_thickness], center=true);
}

module edge_chamfer_shape() {
  translate([0, 0, sheet_thickness/2 - edge_chamfer/2])
    cube([sheet_length + 2*overlap, sheet_width + 2*overlap, edge_chamfer], center=true);
}

module corner_radius_shape() {
  cube([sheet_length - 2*corner_radius, sheet_width - 2*corner_radius, sheet_thickness + 2*overlap], center=true);
}

// Operations
module sheet_with_edge_chamfer() {
  difference() {
    mdf_sheet_body();
    edge_chamfer_shape();
  }
}

module sheet_with_corner_radius() {
  intersection() {
    sheet_with_edge_chamfer();
    corner_radius_shape();
  }
}

// Final Model
module final_model() {
  union() {
    sheet_with_corner_radius();
  }
}

// Render the final model
color([0.85, 0.85, 0.8]) // MDF color
final_model();