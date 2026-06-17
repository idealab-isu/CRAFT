$fn = 128;

// HT 32 pipe (approx.): OD 32 mm, wall 1.8 mm, length 1000 mm
od = 32;
wall = 1.8;
id = od - 2*wall;
len = 1000;

eps = 0.2;

rotate([90, 0, 0])  // lay pipe along X so orthographic views show length clearly
difference() {
    cylinder(h = len, d = od, center = true);
    cylinder(h = len + 2*eps, d = id, center = true);
}