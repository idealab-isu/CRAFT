// Flat washer: 3.5mm ID, 8.0mm OD, 0.5mm thickness

inner_diameter_mm = 3.5;
outer_diameter_mm = 8.0;
thickness_mm      = 0.5;

eps_mm = 0.02;
$fn = 128;

difference() {
    cylinder(d = outer_diameter_mm, h = thickness_mm, center = true);
    cylinder(d = inner_diameter_mm, h = thickness_mm + 2*eps_mm, center = true);
}