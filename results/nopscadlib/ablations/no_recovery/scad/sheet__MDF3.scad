// Parameters
sheet_L = 600; //[300:1200:1]
sheet_W = 400; //[200:800:1]
sheet_T = 18; //[9:36:1]
chamfer_size = 1.5; //[0.5:6:0.5]
corner_radius = 6; //[2:20:1]
overlap = 1; //[0.5:2:0.5]

// Base Shapes
module mdf_sheet_panel() {
  color([0.85, 0.85, 0.8]) // MDF color
  cube([sheet_L, sheet_W, sheet_T], center=true);
}

module edge_chamfer() {
  color([0.85, 0.85, 0.8]) // MDF color
  cube([chamfer_size, chamfer_size, sheet_T + 2*overlap], center=true);
}

module corner_rounding() {
  color([0.85, 0.85, 0.8]) // MDF color
  cylinder(h=sheet_T + 2*overlap, r=corner_radius, center=true);
}

module material_label_text() {
  color([0.85, 0.85, 0.8]) // MDF color
  cube([sheet_L/10, sheet_W/10, sheet_T/10], center=true);
}

// Operations
module edge_chamfer_all() {
  union() {
    translate([sheet_L/2 - chamfer_size/2, sheet_W/2 - chamfer_size/2, 0]) edge_chamfer();
    translate([sheet_L/2 - chamfer_size/2, -(sheet_W/2 - chamfer_size/2), 0]) edge_chamfer();
    translate([-(sheet_L/2 - chamfer_size/2), sheet_W/2 - chamfer_size/2, 0]) edge_chamfer();
    translate([-(sheet_L/2 - chamfer_size/2), -(sheet_W/2 - chamfer_size/2), 0]) edge_chamfer();
  }
}

module corner_rounding_all() {
  union() {
    translate([sheet_L/2 - corner_radius, sheet_W/2 - corner_radius, 0]) corner_rounding();
    translate([sheet_L/2 - corner_radius, -(sheet_W/2 - corner_radius), 0]) corner_rounding();
    translate([-(sheet_L/2 - corner_radius), sheet_W/2 - corner_radius, 0]) corner_rounding();
    translate([-(sheet_L/2 - corner_radius), -(sheet_W/2 - corner_radius), 0]) corner_rounding();
  }
}

module final_model() {
  difference() {
    difference() {
      mdf_sheet_panel();
      corner_rounding_all();
    }
    edge_chamfer_all();
  }
  translate([0, 0, sheet_T/2 - (sheet_T/10)/2]) material_label_text();
}

// Render the final model
final_model();