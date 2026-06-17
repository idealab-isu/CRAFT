// Penny washer parameters (mm)
inner_diameter_mm = 5.0;
outer_diameter_mm = 20.0;
thickness_mm      = 1.4;

// Small epsilon for robust boolean ops
eps_mm = 0.05;

$fn = 128;

// Single-part penny washer
difference() {
    cylinder(d = outer_diameter_mm, h = thickness_mm, center = true);
    cylinder(d = inner_diameter_mm, h = thickness_mm + 2*eps_mm, center = true);
}