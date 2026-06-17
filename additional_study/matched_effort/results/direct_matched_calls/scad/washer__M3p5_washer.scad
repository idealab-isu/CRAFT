$fn = 128;

inner_d = 3.5;
outer_d = 8.0;
thickness = 0.5;

difference() {
  cylinder(d = outer_d, h = thickness);
  cylinder(d = inner_d, h = thickness + 0.2);
}