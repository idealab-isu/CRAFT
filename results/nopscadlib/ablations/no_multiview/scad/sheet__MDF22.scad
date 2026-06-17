// Parameters
sheet_length = 2440; //[1220:4880:1]
sheet_width = 1220; //[610:2440:1]
sheet_thickness = 18; //[9:36:1]
corner_radius = 6; //[0:30:1]
edge_chamfer = 1; //[0:3:0.5]
connect_overlap = 1; //[0.5:2:0.5]

// Base Shapes
module mdf_sheet_panel() {
  cube([sheet_length, sheet_width, sheet_thickness], center=true);
}

module corner_rounding() {
  cube([sheet_length - 2*corner_radius, sheet_width - 2*corner_radius, sheet_thickness], center=true);
}

module corner_rounding_cyl_1() {
  translate([sheet_length/2 - corner_radius, sheet_width/2 - corner_radius, 0])
    cylinder(r=corner_radius, h=sheet_thickness, center=true);
}

module corner_rounding_cyl_2() {
  translate([-sheet_length/2 + corner_radius, sheet_width/2 - corner_radius, 0])
    cylinder(r=corner_radius, h=sheet_thickness, center=true);
}

module corner_rounding_cyl_3() {
  translate([-sheet_length/2 + corner_radius, -sheet_width/2 + corner_radius, 0])
    cylinder(r=corner_radius, h=sheet_thickness, center=true);
}

module corner_rounding_cyl_4() {
  translate([sheet_length/2 - corner_radius, -sheet_width/2 + corner_radius, 0])
    cylinder(r=corner_radius, h=sheet_thickness, center=true);
}

module edge_chamfer_top_inset() {
  translate([0, 0, sheet_thickness/4])
    cube([sheet_length - 2*edge_chamfer, sheet_width - 2*edge_chamfer, sheet_thickness/2 + connect_overlap], center=true);
}

module edge_chamfer_bottom_inset() {
  translate([0, 0, -sheet_thickness/4])
    cube([sheet_length - 2*edge_chamfer, sheet_width - 2*edge_chamfer, sheet_thickness/2 + connect_overlap], center=true);
}

module surface_label_text() {
  translate([0, 0, sheet_thickness/2 - (sheet_thickness/100)])
    cube([sheet_length/10, sheet_width/10, sheet_thickness/50], center=true);
}

// Operations
module corner_rounding_union() {
  union() {
    corner_rounding();
    corner_rounding_cyl_1();
    corner_rounding_cyl_2();
    corner_rounding_cyl_3();
    corner_rounding_cyl_4();
  }
}

module edge_chamfer() {
  hull() {
    edge_chamfer_top_inset();
    edge_chamfer_bottom_inset();
  }
}

module sheet_with_rounding() {
  intersection() {
    mdf_sheet_panel();
    corner_rounding_union();
  }
}

module sheet_with_rounding_and_chamfer() {
  intersection() {
    sheet_with_rounding();
    edge_chamfer();
  }
}

module complete_model() {
  union() {
    sheet_with_rounding_and_chamfer();
    surface_label_text();
  }
}

// Final Output
complete_model();