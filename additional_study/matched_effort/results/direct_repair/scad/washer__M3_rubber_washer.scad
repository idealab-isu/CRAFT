$fn = 128;

inner_d = 3.0;
outer_d = 10.0;
thickness = 1.5;

difference() {
  cylinder(d = outer_d, h = thickness);
  cylinder(d = inner_d, h = thickness + 0.2);
}