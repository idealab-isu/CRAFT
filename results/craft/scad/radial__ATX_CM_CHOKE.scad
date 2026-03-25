// Parameters
outer_radius = 17.4; //[8.7:34.8:0.1]
inner_radius = 11.4; //[5.7:22.8:0.1]
height = 9; //[4.5:18:0.1]
rim_thickness = 0.5; //[0.25:1:0.05]
overlap = 1; //[0.5:2:0.1]

// Base Shapes
module annular_outer_cyl() {
  cylinder(r=outer_radius, h=height, center=true);
}

module annular_inner_hole_cyl() {
  cylinder(r=inner_radius, h=height + 2*overlap, center=true);
}

module rim_outer_cyl() {
  cylinder(r=outer_radius, h=height, center=true);
}

module rim_inner_cut_cyl() {
  cylinder(r=outer_radius - rim_thickness, h=height + 2*overlap, center=true);
}

// Operations
module annular_main_body() {
  difference() {
    annular_outer_cyl();
    annular_inner_hole_cyl();
  }
}

module rim_or_lip_feature() {
  difference() {
    rim_outer_cyl();
    rim_inner_cut_cyl();
  }
}

// Final Output
module complete_model() {
  union() {
    annular_main_body();
    rim_or_lip_feature();
  }
}

// Render the complete model
complete_model();