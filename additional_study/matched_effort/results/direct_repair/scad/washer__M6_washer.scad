$fn = 128;

inner_d = 6.0;
outer_d = 12.5;
thickness = 1.5;

difference() {
  cylinder(d = outer_d, h = thickness);
  translate([0, 0, -0.1])
    cylinder(d = inner_d, h = thickness + 0.2);
}