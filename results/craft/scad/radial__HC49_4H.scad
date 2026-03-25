// Parameters
outer_radius = 10.5; //[5.25:21:0.1]
inner_radius = 3.7; //[1.85:7.4:0.1]
thickness = 3.5; //[1.75:7:0.1]

// Geometry
module radial_outer_cyl() {
  cylinder(r=outer_radius, h=thickness, center=true);
}

module radial_inner_hole_cyl() {
  cylinder(r=inner_radius, h=thickness, center=true);
}

// Final Output
difference() {
  radial_outer_cyl();
  radial_inner_hole_cyl();
}