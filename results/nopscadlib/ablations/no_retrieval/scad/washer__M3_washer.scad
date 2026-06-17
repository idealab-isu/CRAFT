// Flat washer: 3.0mm inner hole, 7.0mm outer diameter, 0.5mm thickness

outer_diameter = 7.0;
inner_diameter = 3.0;
thickness      = 0.5;

$fn = 128;

eps = 0.02; // small overlap to ensure clean boolean

difference() {
    cylinder(r = outer_diameter/2, h = thickness, center = true);
    cylinder(r = inner_diameter/2, h = thickness + 2*eps, center = true);
}