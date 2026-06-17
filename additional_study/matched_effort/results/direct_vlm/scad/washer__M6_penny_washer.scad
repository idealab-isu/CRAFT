$fn = 180;

inner_d = 6.0;
outer_d = 26.0;
thickness = 1.5;

difference() {
  cylinder(h = thickness, d = outer_d);
  translate([0, 0, -0.1])
    cylinder(h = thickness + 0.2, d = inner_d);
}