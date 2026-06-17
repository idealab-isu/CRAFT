// Parameters
sheet_length = 600; //[300:1200:1]
sheet_width = 400; //[200:800:1]
sheet_thickness = 18; //[9:36:1]
corner_radius = 12; //[6:24:1]
chamfer_size = 1.5; //[0.5:3:0.1]
grain_depth = 0.3; //[0.1:0.8:0.05]
grain_pitch = 18; //[8:40:1]
grain_groove_width = 2.5; //[1:6:0.1]
grain_margin = 10; //[5:25:1]
overlap = 1; //[0.5:2:0.1]

// Base Shapes
module mdf_sheet() {
  cube([sheet_length, sheet_width, sheet_thickness], center=true);
}

module corner_rounding() {
  sphere(r=corner_radius, center=true);
}

module edge_chamfer() {
  sphere(r=chamfer_size, center=true);
}

module surface_texture_grain() {
  cube([sheet_length - 2*grain_margin, grain_groove_width, grain_depth + overlap], center=true);
}

// Operations
module op_corner_rounding_minkowski() {
  minkowski() {
    mdf_sheet();
    corner_rounding();
  }
}

module op_edge_chamfer_minkowski() {
  minkowski() {
    op_corner_rounding_minkowski();
    edge_chamfer();
  }
}

module op_grain_grooves_union() {
  union() {
    for (i = [-3:3]) {
      translate([0, i * grain_pitch, 0]) surface_texture_grain();
    }
  }
}

module op_sheet_with_grain() {
  difference() {
    op_edge_chamfer_minkowski();
    op_grain_grooves_union();
  }
}

// Final Output
color([0.85, 0.85, 0.8]) // MDF color
op_sheet_with_grain();