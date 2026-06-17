// Parameters
sheet_L = 1000; //[500:2000:1]
sheet_W = 500; //[250:1000:1]
sheet_T = 3; //[1.5:6:0.1]
corner_R = 20; //[10:40:1]
chamfer_C = 1; //[0.5:3:0.1]
hole_d = 6; //[3:12:0.5]
hole_edge_offset = 25; //[10:60:1]
hole_clearance_z = 2; //[1:10:0.5]

// Base shapes
module sheet_panel_base() {
  cube([sheet_L - 2*corner_R, sheet_W - 2*corner_R, sheet_T], center=true);
}

module corner_rounding_cyl() {
  cylinder(r=corner_R, h=sheet_T, center=true);
}

module edge_chamfer_bevel() {
  cylinder(r1=chamfer_C, r2=0, h=chamfer_C, center=true);
}

module mounting_hole_cutter() {
  cylinder(r=hole_d/2, h=sheet_T + hole_clearance_z, center=true);
}

// Operations
module corner_rounding() {
  union() {
    sheet_panel_base();
    translate([-(sheet_L/2 - corner_R), (sheet_W/2 - corner_R), 0]) corner_rounding_cyl();
    translate([(sheet_L/2 - corner_R), (sheet_W/2 - corner_R), 0]) corner_rounding_cyl();
    translate([-(sheet_L/2 - corner_R), -(sheet_W/2 - corner_R), 0]) corner_rounding_cyl();
    translate([(sheet_L/2 - corner_R), -(sheet_W/2 - corner_R), 0]) corner_rounding_cyl();
  }
}

module edge_chamfer() {
  minkowski() {
    corner_rounding();
    edge_chamfer_bevel();
  }
}

module complete_model() {
  difference() {
    edge_chamfer();
    translate([-(sheet_L/2 - hole_edge_offset), (sheet_W/2 - hole_edge_offset), 0]) mounting_hole_cutter();
    translate([(sheet_L/2 - hole_edge_offset), (sheet_W/2 - hole_edge_offset), 0]) mounting_hole_cutter();
    translate([-(sheet_L/2 - hole_edge_offset), -(sheet_W/2 - hole_edge_offset), 0]) mounting_hole_cutter();
    translate([(sheet_L/2 - hole_edge_offset), -(sheet_W/2 - hole_edge_offset), 0]) mounting_hole_cutter();
  }
}

// Final output
complete_model();