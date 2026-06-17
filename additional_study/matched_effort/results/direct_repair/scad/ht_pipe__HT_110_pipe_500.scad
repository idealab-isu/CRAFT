$fn = 128;

// HT 110 pipe (approx.): OD 110 mm, wall 3.2 mm, length 500 mm
od = 110;
wall = 3.2;
id = od - 2*wall;
len = 500;

difference() {
    cylinder(h = len, d = od);
    translate([0,0,-0.1]) cylinder(h = len + 0.2, d = id);
}