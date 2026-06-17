$fn = 128;

r = 10.5;
h = 3.7;
t = 3.5;

difference() {
  cylinder(r = r, h = h);
  translate([0,0,-0.01])
    cylinder(r = max(r - t, 0.01), h = h + 0.02);
}