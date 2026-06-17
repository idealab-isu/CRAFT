$fn = 128;

inner_d = 2.0;
outer_d = 5.0;
thickness = 0.3;

difference() {
  cylinder(d = outer_d, h = thickness);
  cylinder(d = inner_d, h = thickness + 0.2);
}