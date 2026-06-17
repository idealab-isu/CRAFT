$fn = 128;

// HT 40 pipe (approx.): DN40, OD 40 mm, length 150 mm
// Assumed wall thickness ~1.8 mm (typical for HT indoor drainage pipe)
od = 40;
wall = 1.8;
id = od - 2*wall;
len = 150;

difference() {
  cylinder(h = len, d = od);
  translate([0,0,-0.1])
    cylinder(h = len + 0.2, d = id);
}