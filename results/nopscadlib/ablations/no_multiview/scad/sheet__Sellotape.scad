// Parameters
tape_L = 100; //[50:200:1]
tape_W = 19; //[10:40:1]
tape_T = 0.05; //[0.02:0.2:0.01]
edge_R = 0.5; //[0.2:1.5:0.1]
overlap = 0.5; //[0.2:2:0.1]
torn_depth = 0.6; //[0.2:2:0.1]
torn_notch_W = 3; //[1:8:0.5]
torn_count = 5; //[2:12:1]

// Base shapes
module tape_sheet() {
  cube([tape_L, tape_W, tape_T], center=true);
}

module tape_edge_rounding() {
  sphere(r=edge_R, center=true);
}

module torn_notch(position_y) {
  translate([tape_L/2 - torn_depth/2 + overlap, position_y, 0])
    cube([torn_depth, torn_notch_W, tape_T + 2*overlap], center=true);
}

// Operations
module semi_transparent_material_hint() {
  minkowski() {
    tape_sheet();
    tape_edge_rounding();
  }
}

module torn_edge_detail() {
  difference() {
    semi_transparent_material_hint();
    for (i = [-2, -1, 0, 1, 2]) {
      torn_notch(i * torn_notch_W);
    }
  }
}

// Final output
color([0.85, 0.85, 0.8]) // Off-white color for adhesive tape
torn_edge_detail();