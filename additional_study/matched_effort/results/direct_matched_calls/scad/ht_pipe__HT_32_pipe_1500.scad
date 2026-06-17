$fn = 128;

// HT 32 pipe (approx): OD 32 mm, wall 1.8 mm, length 1500 mm
od = 32;
wall = 1.8;
id = od - 2*wall;
len = 1500;

difference() {
  cylinder(h = len, d = od);
  translate([0,0,-0.5])
    cylinder(h = len + 1, d = id);
}