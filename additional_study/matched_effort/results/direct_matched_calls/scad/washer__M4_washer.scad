$fn = 128;

inner_d = 4.0;
outer_d = 9.0;
thickness = 0.8;

difference() {
  cylinder(h = thickness, d = outer_d);
  cylinder(h = thickness + 0.2, d = inner_d);
}