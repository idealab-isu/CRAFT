$fn = 128;

bore_d = 8.0;
outer_d = 15.0;
length = 24.0;

difference() {
  cylinder(d = outer_d, h = length, center = false);
  translate([0, 0, -0.1])
    cylinder(d = bore_d, h = length + 0.2, center = false);
}