// Parameters
outer_radius = 17.4; //[8.7:34.8:0.1]
inner_radius = 11.4; //[5.7:22.8:0.1]
height = 9.0; //[4.5:18.0:0.1]
wall_thickness = 0.5; //[0.25:1.0:0.05]
overlap = 1.0; //[0.5:2.0:0.1]

// Geometry
module radial_main_body_outer() {
  cylinder(h=height, r=outer_radius, center=true);
}

module radial_main_body_inner_void() {
  cylinder(h=height + 2*overlap, r=outer_radius - wall_thickness, center=true);
}

// Final Output
difference() {
  radial_main_body_outer();
  radial_main_body_inner_void();
}