// Rubber washer: 3.0mm inner hole, 10.0mm outer diameter, 1.5mm thickness

inner_diameter_mm = 3.0;   //[1.5:6.0:0.1]
outer_diameter_mm = 10.0;  //[5.0:20.0:0.1]
thickness_mm      = 1.5;   //[0.75:3.0:0.05]

inner_radius_mm = inner_diameter_mm / 2;
outer_radius_mm = outer_diameter_mm / 2;

$fn = 128;

module washer() {
  color([0.2, 0.2, 0.2])  // rubber
  difference() {
    cylinder(r = outer_radius_mm, h = thickness_mm, center = true);
    cylinder(r = inner_radius_mm, h = thickness_mm + 0.2, center = true); // ensure clean through-hole
  }
}

washer();