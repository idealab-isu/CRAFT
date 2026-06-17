// Parameters
sheet_L = 600; //[300:1200:1]
sheet_W = 400; //[200:800:1]
sheet_T = 18; //[9:36:1]
corner_R = 8; //[2:16:1]
chamfer_C = 1.5; //[0.5:3:0.1]
eps = 0.8; //[0.2:2:0.1]

// Base Shapes
module mdf_sheet_panel() {
  cube([sheet_L, sheet_W, sheet_T], center=true);
}

module corner_rounding() {
  linear_extrude(height=sheet_T + 2*eps, center=true) {
    polygon(points=[
      [-sheet_L/2 + corner_R, -sheet_W/2],
      [sheet_L/2 - corner_R, -sheet_W/2],
      [sheet_L/2, -sheet_W/2 + corner_R],
      [sheet_L/2, sheet_W/2 - corner_R],
      [sheet_L/2 - corner_R, sheet_W/2],
      [-sheet_L/2 + corner_R, sheet_W/2],
      [-sheet_L/2, sheet_W/2 - corner_R],
      [-sheet_L/2, -sheet_W/2 + corner_R]
    ]);
  }
}

module edge_chamfer() {
  linear_extrude(height=sheet_T + 2*eps, center=true) {
    polygon(points=[
      [-sheet_L/2 + chamfer_C, -sheet_W/2 + chamfer_C],
      [sheet_L/2 - chamfer_C, -sheet_W/2 + chamfer_C],
      [sheet_L/2 - chamfer_C, sheet_W/2 - chamfer_C],
      [-sheet_L/2 + chamfer_C, sheet_W/2 - chamfer_C]
    ]);
  }
}

module material_label_text() {
  cube([eps, eps, eps], center=true);
}

// Operations
module op_round_corners() {
  intersection() {
    mdf_sheet_panel();
    corner_rounding();
  }
}

module op_edge_chamfer_approx() {
  intersection() {
    op_round_corners();
    edge_chamfer();
  }
}

module op_final_union() {
  union() {
    op_edge_chamfer_approx();
    material_label_text();
  }
}

// Final Output
op_final_union();