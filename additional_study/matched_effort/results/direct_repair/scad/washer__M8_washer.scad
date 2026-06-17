$fn = 128;

inner_d = 8.0;
outer_d = 17.0;
thickness = 1.6;

difference() {
  cylinder(d = outer_d, h = thickness);
  translate([0, 0, -0.1])
    cylinder(d = inner_d, h = thickness + 0.2);
}