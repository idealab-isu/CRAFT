$fn = 128;

inner_d = 3.0;
outer_d = 10.0;
thickness = 1.5;

difference() {
  cylinder(h = thickness, d = outer_d);
  cylinder(h = thickness + 0.2, d = inner_d);
}