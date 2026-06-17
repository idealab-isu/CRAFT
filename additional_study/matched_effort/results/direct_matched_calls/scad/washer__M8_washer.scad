$fn = 180;

inner_d = 8.0;
outer_d = 17.0;
thickness = 1.6;

difference() {
  cylinder(h = thickness, d = outer_d);
  cylinder(h = thickness + 0.2, d = inner_d);
}