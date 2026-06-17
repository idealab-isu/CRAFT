$fn = 128;

// HT 40 pipe (approx.): DN40, OD 40 mm, wall ~1.8 mm, length 1000 mm
length = 1000;
od = 40;
wall = 1.8;
id = od - 2*wall;

difference() {
    cylinder(h = length, d = od, center = false);
    translate([0,0,-0.1])
        cylinder(h = length + 0.2, d = id, center = false);
}