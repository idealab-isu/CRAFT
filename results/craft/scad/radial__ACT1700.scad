// Parameters
outer_radius = 10.8; //[5.4:21.6:0.1]
inner_radius = 10.8; //[5.4:21.6:0.1]
height = 5.3; //[2.65:10.6:0.1]
thickness = 1.0; //[0.5:2.0:0.1]
overlap = 0.8; //[0.5:2.0:0.1]

// Main radial feature
module radial_main_profile() {
  color("Silver")
  cylinder(r=outer_radius, h=height, center=true);
}

// Radial step outer cylinder
module radial_step_outer_cyl() {
  color("DimGray")
  cylinder(r=outer_radius + thickness, h=height, center=true);
}

// Radial step inner cylinder
module radial_step_inner_cyl() {
  color("Black")
  cylinder(r=outer_radius - overlap, h=height + overlap*2, center=true);
}

// Radial step or wall
module radial_step_or_wall() {
  difference() {
    radial_step_outer_cyl();
    radial_step_inner_cyl();
  }
}

// Complete radial feature
module radial_feature_complete() {
  union() {
    radial_main_profile();
    radial_step_or_wall();
  }
}

// Final output
radial_feature_complete();