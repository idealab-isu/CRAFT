// Parameters
r_outer = 10.8; //[5.4:21.6:0.1]
r_inner = 5.3; //[2.65:10.6:0.1]
height = 1; //[0.5:2:0.1]
overlap = 1; //[0.5:2:0.1]

// Geometry
module radial_body_outer() {
  cylinder(r=r_outer, h=height, center=true);
}

module radial_body_inner_cut() {
  cylinder(r=r_inner, h=height + 2*overlap, center=true);
}

// Final Output
difference() {
  radial_body_outer();
  radial_body_inner_cut();
}