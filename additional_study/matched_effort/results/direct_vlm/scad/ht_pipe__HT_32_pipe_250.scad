$fn = 128;

// HT 32 pipe (approx.): OD 32 mm, wall 1.8 mm, length 250 mm
od = 32;
wall = 1.8;
id = od - 2*wall;
len = 250;

difference() {
  cylinder(h = len, d = od);
  translate([0,0,-0.1]) cylinder(h = len + 0.2, d = id);
}