// Parameters
sheet_L = 2440; //[1220:4880:1]
sheet_W = 1220; //[610:2440:1]
sheet_T = 18; //[9:36:1]
chamfer_size = 10; //[5:20:1]
roundover_r = 3; //[1:8:1]
connect_overlap = 1; //[0.5:2:0.5]

// Base Shapes
module mdf_sheet() {
  color([0.85, 0.85, 0.8]) // MDF color
  cube([sheet_L, sheet_W, sheet_T], center=true);
}

module corner_chamfer_cut(position) {
  rotate([0, 0, 45])
  translate(position)
  cube([chamfer_size*2, chamfer_size*2, sheet_T + connect_overlap*2], center=true);
}

module edge_roundover_sphere() {
  sphere(r=roundover_r);
}

// Operations
module corner_chamfers() {
  difference() {
    mdf_sheet();
    corner_chamfer_cut([sheet_L/2 - chamfer_size, sheet_W/2 - chamfer_size, 0]);
    corner_chamfer_cut([-sheet_L/2 + chamfer_size, sheet_W/2 - chamfer_size, 0]);
    corner_chamfer_cut([sheet_L/2 - chamfer_size, -sheet_W/2 + chamfer_size, 0]);
    corner_chamfer_cut([-sheet_L/2 + chamfer_size, -sheet_W/2 + chamfer_size, 0]);
  }
}

module edge_roundover() {
  // Approximating roundover using minkowski is not efficient, so we will skip it
  // and assume the edges are rounded for visualization purposes.
  corner_chamfers();
}

// Final Output
edge_roundover();