// Flat washer: 8.0mm ID, 17.0mm OD, 1.6mm thickness

inner_diameter_mm = 8.0;
outer_diameter_mm = 17.0;
thickness_mm      = 1.6;

eps_mm = 0.02;          // small overlap for clean boolean
$fn = 128;

difference() {
    cylinder(d=outer_diameter_mm, h=thickness_mm, center=true);
    cylinder(d=inner_diameter_mm, h=thickness_mm + 2*eps_mm, center=true);
}