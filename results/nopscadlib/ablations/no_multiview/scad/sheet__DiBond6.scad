// Parameters
sheet_L = 1000; //[500:2000:1]
sheet_W = 500; //[250:1000:1]
sheet_T = 3; //[1.5:6:0.1]
corner_R = 20; //[5:40:1]
chamfer_C = 1; //[0.5:3:0.1]
hole_D = 6; //[3:12:0.5]
hole_edge_offset = 25; //[10:60:1]
hole_clear_Z = 2; //[1:10:0.5]
overlap = 1; //[0.5:2:0.1]

// Base Shapes
module sheet_panel() {
  translate([0, 0, 0])
    cube([sheet_L, sheet_W, sheet_T], center=true);
}

module rounded_corner_cut_cyl() {
  translate([0, 0, 0])
    cylinder(h=sheet_T + 2*overlap, r=corner_R, center=true);
}

module rounded_corner_cut_box() {
  translate([0, 0, 0])
    cube([corner_R, corner_R, sheet_T + 2*overlap], center=true);
}

module hole_cutter() {
  translate([0, 0, 0])
    cylinder(h=sheet_T + hole_clear_Z, r=hole_D/2, center=true);
}

module chamfer_cut_x() {
  translate([0, 0, 0])
    rotate([45, 0, 0])
      cube([sheet_L + 2*overlap, chamfer_C, chamfer_C], center=true);
}

module chamfer_cut_y() {
  translate([0, 0, 0])
    rotate([0, 45, 0])
      cube([chamfer_C, sheet_W + 2*overlap, chamfer_C], center=true);
}

// Operations
module rounded_corner_cut_NE() {
  intersection() {
    translate([sheet_L/2 - corner_R/2 + overlap, sheet_W/2 - corner_R/2 + overlap, 0])
      rounded_corner_cut_box();
    translate([sheet_L/2 - corner_R + overlap, sheet_W/2 - corner_R + overlap, 0])
      rounded_corner_cut_cyl();
  }
}

module rounded_corner_cut_NW() {
  mirror([1, 0, 0])
    rounded_corner_cut_NE();
}

module rounded_corner_cut_SE() {
  mirror([0, 1, 0])
    rounded_corner_cut_NE();
}

module rounded_corner_cut_SW() {
  mirror([0, 1, 0])
    rounded_corner_cut_NW();
}

module rounded_corners() {
  union() {
    rounded_corner_cut_NE();
    rounded_corner_cut_NW();
    rounded_corner_cut_SE();
    rounded_corner_cut_SW();
  }
}

module mounting_holes() {
  union() {
    translate([sheet_L/2 - hole_edge_offset, sheet_W/2 - hole_edge_offset, 0])
      hole_cutter();
    translate([-sheet_L/2 + hole_edge_offset, sheet_W/2 - hole_edge_offset, 0])
      hole_cutter();
    translate([sheet_L/2 - hole_edge_offset, -sheet_W/2 + hole_edge_offset, 0])
      hole_cutter();
    translate([-sheet_L/2 + hole_edge_offset, -sheet_W/2 + hole_edge_offset, 0])
      hole_cutter();
  }
}

module edge_chamfer() {
  union() {
    translate([0, sheet_W/2 - chamfer_C/2 + overlap, sheet_T/2 - chamfer_C/2 + overlap])
      chamfer_cut_x();
    translate([0, -sheet_W/2 + chamfer_C/2 - overlap, sheet_T/2 - chamfer_C/2 + overlap])
      chamfer_cut_x();
    translate([sheet_L/2 - chamfer_C/2 + overlap, 0, sheet_T/2 - chamfer_C/2 + overlap])
      chamfer_cut_y();
    translate([-sheet_L/2 + chamfer_C/2 - overlap, 0, sheet_T/2 - chamfer_C/2 + overlap])
      chamfer_cut_y();
  }
}

// Final Model
difference() {
  difference() {
    difference() {
      sheet_panel();
      rounded_corners();
    }
    mounting_holes();
  }
  edge_chamfer();
}