// Parameters
sheet_L = 200; //[100:400:1]
sheet_W = 100; //[50:200:1]
sheet_T = 2; //[1:6:0.5]
corner_R = 10; //[5:20:1]
chamfer_C = 1; //[0.5:3:0.5]
hole_d = 6; //[3:12:0.5]
hole_edge_offset = 15; //[8:30:1]
hole_clearance_z = 2; //[1:6:0.5]
overlap = 1; //[0.5:2:0.5]

// Base Shapes
module sheet_body() {
  translate([0, 0, 0])
    cube([sheet_L, sheet_W, sheet_T], center=true);
}

module corner_rounds() {
  translate([sheet_L/2 - corner_R, sheet_W/2 - corner_R, 0])
    cylinder(r=corner_R, h=sheet_T + 2*overlap, center=true);
}

module corner_rounds_2() {
  translate([-sheet_L/2 + corner_R, sheet_W/2 - corner_R, 0])
    cylinder(r=corner_R, h=sheet_T + 2*overlap, center=true);
}

module corner_rounds_3() {
  translate([-sheet_L/2 + corner_R, -sheet_W/2 + corner_R, 0])
    cylinder(r=corner_R, h=sheet_T + 2*overlap, center=true);
}

module corner_rounds_4() {
  translate([sheet_L/2 - corner_R, -sheet_W/2 + corner_R, 0])
    cylinder(r=corner_R, h=sheet_T + 2*overlap, center=true);
}

module corner_cut_1() {
  translate([sheet_L/2 - corner_R/2, sheet_W/2 - corner_R/2, 0])
    cube([corner_R, corner_R, sheet_T + 2*overlap], center=true);
}

module corner_cut_2() {
  translate([-sheet_L/2 + corner_R/2, sheet_W/2 - corner_R/2, 0])
    cube([corner_R, corner_R, sheet_T + 2*overlap], center=true);
}

module corner_cut_3() {
  translate([-sheet_L/2 + corner_R/2, -sheet_W/2 + corner_R/2, 0])
    cube([corner_R, corner_R, sheet_T + 2*overlap], center=true);
}

module corner_cut_4() {
  translate([sheet_L/2 - corner_R/2, -sheet_W/2 + corner_R/2, 0])
    cube([corner_R, corner_R, sheet_T + 2*overlap], center=true);
}

module edge_chamfer() {
  translate([0, 0, sheet_T/2 - chamfer_C/2 + overlap/2])
    cube([sheet_L - 2*corner_R, sheet_W - 2*corner_R, chamfer_C], center=true);
}

module edge_chamfer_2() {
  translate([0, 0, -sheet_T/2 + chamfer_C/2 - overlap/2])
    cube([sheet_L - 2*corner_R, sheet_W - 2*corner_R, chamfer_C], center=true);
}

module mounting_holes() {
  translate([sheet_L/2 - hole_edge_offset, sheet_W/2 - hole_edge_offset, 0])
    cylinder(r=hole_d/2, h=sheet_T + hole_clearance_z, center=true);
}

module mounting_holes_2() {
  translate([-sheet_L/2 + hole_edge_offset, sheet_W/2 - hole_edge_offset, 0])
    cylinder(r=hole_d/2, h=sheet_T + hole_clearance_z, center=true);
}

module mounting_holes_3() {
  translate([-sheet_L/2 + hole_edge_offset, -sheet_W/2 + hole_edge_offset, 0])
    cylinder(r=hole_d/2, h=sheet_T + hole_clearance_z, center=true);
}

module mounting_holes_4() {
  translate([sheet_L/2 - hole_edge_offset, -sheet_W/2 + hole_edge_offset, 0])
    cylinder(r=hole_d/2, h=sheet_T + hole_clearance_z, center=true);
}

module material_tag() {
  translate([0, 0, 0])
    cube([sheet_L, sheet_W, sheet_T], center=true);
}

// Operations
module rounded_corners_union() {
  union() {
    corner_rounds();
    corner_rounds_2();
    corner_rounds_3();
    corner_rounds_4();
  }
}

module corner_cuts_union() {
  union() {
    corner_cut_1();
    corner_cut_2();
    corner_cut_3();
    corner_cut_4();
  }
}

module rounded_sheet_pre() {
  difference() {
    sheet_body();
    corner_cuts_union();
  }
}

module rounded_sheet() {
  union() {
    rounded_sheet_pre();
    rounded_corners_union();
  }
}

module edge_chamfer_union() {
  union() {
    edge_chamfer();
    edge_chamfer_2();
  }
}

module mounting_holes_union() {
  union() {
    mounting_holes();
    mounting_holes_2();
    mounting_holes_3();
    mounting_holes_4();
  }
}

module sheet_with_chamfer() {
  difference() {
    rounded_sheet();
    edge_chamfer_union();
  }
}

module sheet_with_holes() {
  difference() {
    sheet_with_chamfer();
    mounting_holes_union();
  }
}

module complete_model() {
  union() {
    sheet_with_holes();
    material_tag();
  }
}

// Final Output
color("DimGray") complete_model();