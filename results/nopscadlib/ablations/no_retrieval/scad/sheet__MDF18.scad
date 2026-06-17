// Parameters
sheet_L = 600; //[300:1200:1]
sheet_W = 300; //[150:600:1]
sheet_T = 18; //[9:36:1]
corner_R = 10; //[2:30:1]
chamfer_C = 2; //[0.5:6:0.5]
overlap = 1; //[0.5:2:0.5]

// Base Shapes
module mdf_sheet() {
  color([0.85, 0.85, 0.8]) // MDF color
  cube([sheet_L, sheet_W, sheet_T], center=true);
}

module corner_rounding() {
  color([0.85, 0.85, 0.8])
  cylinder(r=corner_R, h=sheet_T + 2*overlap, center=true);
}

module edge_chamfer() {
  color([0.85, 0.85, 0.8])
  rotate([45, 0, 0])
  cube([sheet_L + 2*overlap, chamfer_C, chamfer_C], center=true);
}

module label_text() {
  color([0.85, 0.85, 0.8])
  cube([sheet_L/10, sheet_W/10, sheet_T/10], center=true);
}

// Operations
module corner_rounding_tr() {
  translate([sheet_L/2 - corner_R, sheet_W/2 - corner_R, 0])
  corner_rounding();
}

module corner_rounding_tl() {
  translate([sheet_L/2 - corner_R, -(sheet_W/2 - corner_R), 0])
  corner_rounding();
}

module corner_rounding_br() {
  translate([-(sheet_L/2 - corner_R), sheet_W/2 - corner_R, 0])
  corner_rounding();
}

module corner_rounding_bl() {
  translate([-(sheet_L/2 - corner_R), -(sheet_W/2 - corner_R), 0])
  corner_rounding();
}

module edge_chamfer_top() {
  translate([0, sheet_W/2 - chamfer_C/2 + overlap, sheet_T/2 - chamfer_C/2 + overlap])
  edge_chamfer();
}

module edge_chamfer_bottom() {
  mirror([0, 0, 1])
  edge_chamfer_top();
}

module edge_chamfer_right() {
  rotate([0, 0, 90])
  edge_chamfer_top();
}

module edge_chamfer_left() {
  mirror([1, 0, 0])
  edge_chamfer_right();
}

// Final Model
module complete_model() {
  difference() {
    mdf_sheet();
    corner_rounding_tr();
    corner_rounding_tl();
    corner_rounding_br();
    corner_rounding_bl();
    edge_chamfer_top();
    edge_chamfer_bottom();
    edge_chamfer_right();
    edge_chamfer_left();
  }
  label_text();
}

// Render the complete model
complete_model();