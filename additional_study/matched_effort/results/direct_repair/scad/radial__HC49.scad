$fn = 128;

r = 10.5;
h = 3.7;
t = 13.5;

difference() {
  cylinder(h = h, r = r, center = true);
  cylinder(h = h + 0.2, r = max(0, r - t), center = true);
}