// Parameters
sheet_L = 300; //[150:600:1]
sheet_W = 200; //[100:400:1]
sheet_T = 4; //[2:8:0.1]
liner_T = 0.4; //[0.2:0.8:0.05]
flute_pitch = 8; //[4:16:0.5]
flute_amp = 1.6; //[0.8:3.2:0.1]
corner_R = 6; //[0:20:0.5]
overlap = 1; //[0.5:2:0.1]
tolerance = 0.2; //[0:0.6:0.05]
edge_detail_depth = 1.2; //[0:4:0.1]
edge_detail_enable = 1; //[0:1:1]
texture_depth = 0.15; //[0:0.4:0.05]
texture_pitch = 12; //[6:30:1]

// Base Shapes
module cardboard_sheet_body() {
  cube([sheet_L, sheet_W, sheet_T], center=true);
}

module top_liner_layer() {
  translate([0, 0, sheet_T/2 - liner_T/2])
    cube([sheet_L, sheet_W, liner_T], center=true);
}

module bottom_liner_layer() {
  translate([0, 0, -sheet_T/2 + liner_T/2])
    cube([sheet_L, sheet_W, liner_T], center=true);
}

module fluted_core_layer() {
  cube([sheet_L, sheet_W, sheet_T - 2*liner_T + 2*overlap], center=true);
}

module edge_exposed_flute_detail() {
  linear_extrude(height=edge_detail_depth*edge_detail_enable, center=true)
    translate([sheet_L/2 - (edge_detail_depth*edge_detail_enable)/2 + overlap, 0, 0])
    rotate([0, 90, 0])
    polygon(points=[
      [sheet_W/2, sheet_T/2],
      [sheet_W/2, -sheet_T/2],
      [-sheet_W/2, -sheet_T/2],
      [-sheet_W/2, sheet_T/2]
    ]);
}

module surface_texture() {
  translate([0, sheet_W/2 - texture_pitch/2 + overlap, sheet_T/2 - texture_depth/2 + overlap])
    cube([sheet_L, texture_pitch, texture_depth], center=true);
}

module rounded_corners_cutout() {
  translate([sheet_L/2 - corner_R, sheet_W/2 - corner_R, 0])
    cylinder(r=corner_R, h=sheet_T + 2*overlap, center=true);
}

module manufacturing_tolerances_inset() {
  cube([sheet_L - 2*tolerance, sheet_W - 2*tolerance, sheet_T - 2*tolerance], center=true);
}

// Operations
module rounded_corners() {
  difference() {
    cardboard_sheet_body();
    rounded_corners_cutout();
    mirror([1, 0, 0]) rounded_corners_cutout();
    mirror([0, 1, 0]) rounded_corners_cutout();
    mirror([1, 1, 0]) rounded_corners_cutout();
  }
}

module sheet_layers_union() {
  union() {
    rounded_corners();
    top_liner_layer();
    bottom_liner_layer();
    fluted_core_layer();
  }
}

module sheet_with_edge_detail() {
  union() {
    sheet_layers_union();
    edge_exposed_flute_detail();
  }
}

module sheet_with_surface_texture() {
  union() {
    sheet_with_edge_detail();
    surface_texture();
  }
}

module manufacturing_tolerances() {
  union() {
    sheet_with_surface_texture();
    manufacturing_tolerances_inset();
  }
}

// Final Output
manufacturing_tolerances();