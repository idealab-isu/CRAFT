$fn = 128;

inner_d = 4.0;
outer_d = 9.0;
thickness = 0.8;

difference() {
  cylinder(d = outer_d, h = thickness);
  translate([0, 0, -0.1])
    cylinder(d = inner_d, h = thickness + 0.2);
}