$fn = 128;

inner_d = 2.5;
outer_d = 5.9;
thickness = 0.5;

difference() {
  cylinder(h = thickness, d = outer_d);
  cylinder(h = thickness + 0.2, d = inner_d);
}