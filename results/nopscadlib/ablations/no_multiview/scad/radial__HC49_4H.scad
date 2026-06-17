// Parameters
outer_radius = 10.5; //[5.25:21:0.1]
inner_radius = 3.5; //[1.75:7:0.1]
height = 3.7; //[1.85:7.4:0.1]

// Geometry
module radial_body_outer() {
  cylinder(h=height, r=outer_radius, center=true);
}

module radial_body_inner_cut() {
  cylinder(h=height, r=inner_radius, center=true);
}

// Final Output
difference() {
  radial_body_outer();
  radial_body_inner_cut();
}