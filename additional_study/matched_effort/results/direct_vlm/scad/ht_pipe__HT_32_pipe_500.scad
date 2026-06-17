$fn = 128;

// HT 32 pipe: OD 32 mm, wall 1.8 mm, length 500 mm
od   = 32;
wall = 1.8;
id   = od - 2*wall;
len  = 500;

eps = 0.2;

rotate([90, 0, 0])  // align pipe axis with Y so orthographic views are consistent
difference() {
    cylinder(h = len, d = od, center = true);
    cylinder(h = len + eps, d = id, center = true);
}