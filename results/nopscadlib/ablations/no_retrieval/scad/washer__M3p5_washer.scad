// Flat washer: 3.5mm ID, 8.0mm OD, 0.5mm thickness

id = 3.5;
od = 8.0;
thickness = 0.5;

$fn = 128;

eps = 0.02; // small overlap to ensure clean boolean

difference() {
    cylinder(h = thickness, r = od/2, center = true);
    cylinder(h = thickness + 2*eps, r = id/2, center = true);
}