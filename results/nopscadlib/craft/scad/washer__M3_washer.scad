// Flat washer parameters (mm)
inner_diameter_mm = 3.0;   // 3.0mm hole
outer_diameter_mm = 7.0;   // 7.0mm OD
thickness_mm      = 0.5;   // 0.5mm thick
eps_mm            = 0.05;  // small clearance for clean boolean

$fn = 128;

difference() {
    cylinder(d=outer_diameter_mm, h=thickness_mm, center=true);
    cylinder(d=inner_diameter_mm, h=thickness_mm + 2*eps_mm, center=true);
}