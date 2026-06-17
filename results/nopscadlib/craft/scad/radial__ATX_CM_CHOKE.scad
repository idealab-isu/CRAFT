// Parameters
outer_radius = 17.4; //[8.7:34.8:0.1]
inner_radius = 11.4; //[5.7:22.8:0.1]
height = 9; //[4.5:18:0.5]
wall_thickness = 0.5; //[0.25:1:0.05]
z_overlap = 1; //[0.5:2:0.1]

// Geometry
module radial_body_outer() {
  cylinder(h=height, r=outer_radius, center=true);
}

module radial_body_inner_cut() {
  cylinder(h=height + 2*z_overlap, r=inner_radius, center=true);
}

// Final Output
difference() {
  radial_body_outer();
  radial_body_inner_cut();
}