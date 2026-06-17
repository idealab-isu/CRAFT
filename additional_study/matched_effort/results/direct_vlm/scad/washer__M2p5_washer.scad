$fn = 128;

inner_d = 2.5;
outer_d = 5.9;
thickness = 0.5;

difference() {
  cylinder(d = outer_d, h = thickness);
  translate([0, 0, -0.1])
    cylinder(d = inner_d, h = thickness + 0.2);
}