// Parameters
r_inner = 10.5; //[5.25:21:0.1]
r_outer = 13.5; //[6.75:27:0.1]
thickness = 3.7; //[1.85:7.4:0.1]

// Geometry
module radial_outer_cyl() {
  cylinder(h=thickness, r=r_outer, center=true);
}

module radial_inner_cyl_cut() {
  cylinder(h=thickness, r=r_inner, center=true);
}

// Final Output
difference() {
  radial_outer_cyl();
  radial_inner_cyl_cut();
}