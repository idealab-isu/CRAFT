$fn = 128;

// HT pipe (DIN EN 1451 style) nominal DN40, length 1000 mm
// Typical dimensions (approx.): OD 40 mm, wall 1.8 mm
length = 1000;
od = 40;
wall = 1.8;

id = od - 2*wall;

difference() {
    cylinder(h = length, d = od);
    translate([0,0,-0.1]) cylinder(h = length + 0.2, d = id);
}