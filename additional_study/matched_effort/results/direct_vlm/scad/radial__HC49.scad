$fn = 128;

r = 10.5;
h = 3.7;
t = 13.5;

difference() {
  cylinder(h = h, r = r);
  translate([0, 0, -0.01])
    cylinder(h = h + 0.02, r = max(0, r - t));
}