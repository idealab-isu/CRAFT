// Parameters
sheet_L = 200; //[100:400:1]
sheet_W = 100; //[50:200:1]
sheet_T = 2; //[1:4:0.5]
corner_R = 10; //[5:20:1]
hole_d = 6; //[3:12:0.5]
hole_edge_offset = 15; //[8:30:1]
chamfer_size = 1; //[0.5:3:0.25]
overlap = 1; //[0.5:2:0.5]

// Base Shapes
module sheet_body() {
  translate([0, 0, 0])
    cube([sheet_L, sheet_W, sheet_T], center=true);
}

module corner_rounds_cyl() {
  translate([sheet_L/2 - corner_R, sheet_W/2 - corner_R, 0])
    cylinder(h=sheet_T + 2*overlap, r=corner_R, center=true);
}

module corner_rounds_square() {
  translate([sheet_L/2 - corner_R/2, sheet_W/2 - corner_R/2, 0])
    cube([corner_R, corner_R, sheet_T + 2*overlap], center=true);
}

module mounting_holes_cyl() {
  translate([sheet_L/2 - hole_edge_offset, sheet_W/2 - hole_edge_offset, 0])
    cylinder(h=sheet_T + 2*overlap, r=hole_d/2, center=true);
}

module edge_chamfer_wedge_x() {
  translate([sheet_L/2 - chamfer_size/2, 0, 0])
    rotate([0, 45, 0])
      cube([chamfer_size, sheet_W + 2*overlap, sheet_T + 2*overlap], center=true);
}

module edge_chamfer_wedge_y() {
  translate([0, sheet_W/2 - chamfer_size/2, 0])
    rotate([-45, 0, 0])
      cube([sheet_L + 2*overlap, chamfer_size, sheet_T + 2*overlap], center=true);
}

// Operations
module corner_rounds_quadrant() {
  difference() {
    corner_rounds_square();
    corner_rounds_cyl();
  }
}

module corner_rounds() {
  union() {
    corner_rounds_quadrant();
    mirror([1, 0, 0]) corner_rounds_quadrant();
    mirror([0, 1, 0]) corner_rounds_quadrant();
    mirror([1, 1, 0]) corner_rounds_quadrant();
  }
}

module mounting_holes() {
  union() {
    mounting_holes_cyl();
    mirror([1, 0, 0]) mounting_holes_cyl();
    mirror([0, 1, 0]) mounting_holes_cyl();
    mirror([1, 1, 0]) mounting_holes_cyl();
  }
}

module edge_chamfer() {
  union() {
    edge_chamfer_wedge_x();
    mirror([1, 0, 0]) edge_chamfer_wedge_x();
    edge_chamfer_wedge_y();
    mirror([0, 1, 0]) edge_chamfer_wedge_y();
  }
}

// Final Model
module complete_model() {
  difference() {
    difference() {
      difference() {
        sheet_body();
        corner_rounds();
      }
      mounting_holes();
    }
    edge_chamfer();
  }
}

// Render the complete model
color("DimGray") complete_model();