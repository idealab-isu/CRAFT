// Parameters
sheet_L = 1000; //[500:2000:1]
sheet_W = 500; //[250:1000:1]
sheet_T = 3; //[1.5:6:0.1]
corner_R = 0; //[0:50:1]
hole_d = 5; //[2:12:0.1]
hole_edge_offset = 20; //[5:100:1]
hole_count_x = 2; //[1:10:1]
hole_count_y = 2; //[1:10:1]
edge_chamfer = 0; //[0:2:0.1]
film_T = 0.1; //[0.05:0.3:0.01]
overlap = 1; //[0.5:2:0.1]

// Base shapes
module sheet_panel_base() {
  cube([sheet_L, sheet_W, sheet_T], center=true);
}

module corner_cut_cyl() {
  cylinder(r=corner_R, h=sheet_T + 2*overlap, center=true);
}

module hole_cyl_base() {
  cylinder(r=hole_d/2, h=sheet_T + 2*overlap, center=true);
}

module protective_film_layer() {
  cube([sheet_L, sheet_W, film_T], center=true);
}

module edge_chamfer_layer() {
  cube([sheet_L - 2*edge_chamfer, sheet_W - 2*edge_chamfer, sheet_T], center=true);
}

// Operations
module corner_radius() {
  difference() {
    sheet_panel_base();
    if (corner_R > 0) {
      translate([sheet_L/2 - corner_R, sheet_W/2 - corner_R, 0]) corner_cut_cyl();
      translate([sheet_L/2 - corner_R, -sheet_W/2 + corner_R, 0]) corner_cut_cyl();
      translate([-sheet_L/2 + corner_R, sheet_W/2 - corner_R, 0]) corner_cut_cyl();
      translate([-sheet_L/2 + corner_R, -sheet_W/2 + corner_R, 0]) corner_cut_cyl();
    }
  }
}

module mounting_holes_pattern() {
  union() {
    translate([-sheet_L/2 + hole_edge_offset, -sheet_W/2 + hole_edge_offset, 0]) hole_cyl_base();
    translate([sheet_L/2 - hole_edge_offset, -sheet_W/2 + hole_edge_offset, 0]) hole_cyl_base();
    translate([-sheet_L/2 + hole_edge_offset, sheet_W/2 - hole_edge_offset, 0]) hole_cyl_base();
    translate([sheet_L/2 - hole_edge_offset, sheet_W/2 - hole_edge_offset, 0]) hole_cyl_base();
  }
}

module sheet_with_holes() {
  difference() {
    corner_radius();
    mounting_holes_pattern();
  }
}

module edge_chamfer() {
  intersection() {
    sheet_with_holes();
    edge_chamfer_layer();
  }
}

module complete_model() {
  union() {
    edge_chamfer();
    translate([0, 0, sheet_T/2 + film_T/2 - overlap]) protective_film_layer();
  }
}

// Final output
complete_model();