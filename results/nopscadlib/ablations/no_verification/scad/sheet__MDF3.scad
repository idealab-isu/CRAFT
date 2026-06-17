// Parameters
sheet_length = 600; //[300:1200:1]
sheet_width = 400; //[200:800:1]
sheet_thickness = 18; //[9:36:1]
edge_chamfer_size = 2; //[1:6:1]
corner_round_radius = 10; //[2:40:1]
corner_cut_height = 40; //[10:120:1]
overlap = 1; //[0.5:2:0.5]

// Base Shapes
module mdf_sheet_body() {
  cube([sheet_length, sheet_width, sheet_thickness], center=true);
}

module edge_chamfer() {
  cube([sheet_length - 2*edge_chamfer_size, sheet_width - 2*edge_chamfer_size, sheet_thickness + 2*overlap], center=true);
}

module corner_rounding() {
  cylinder(r=corner_round_radius, h=corner_cut_height, center=true);
}

// Operations
module corner_rounding_all() {
  union() {
    translate([sheet_length/2 - corner_round_radius, sheet_width/2 - corner_round_radius, 0]) corner_rounding();
    translate([-(sheet_length/2 - corner_round_radius), sheet_width/2 - corner_round_radius, 0]) corner_rounding();
    translate([sheet_length/2 - corner_round_radius, -(sheet_width/2 - corner_round_radius), 0]) corner_rounding();
    translate([-(sheet_length/2 - corner_round_radius), -(sheet_width/2 - corner_round_radius), 0]) corner_rounding();
  }
}

module mdf_sheet_with_features() {
  difference() {
    mdf_sheet_body();
    edge_chamfer();
    corner_rounding_all();
  }
}

module final_model() {
  union() {
    mdf_sheet_with_features();
    // Ignoring material_label_text as per rules
  }
}

// Final Output
color([0.85, 0.85, 0.8]) final_model(); // MDF color