// Penny washer parameters (mm)
inner_diameter = 8.0;   // ID
outer_diameter = 30.0;  // OD
thickness      = 1.5;   // thickness
eps            = 0.2;   // boolean clearance

$fn = 180;

// Single penny washer (one connected solid)
difference() {
    cylinder(d = outer_diameter, h = thickness, center = true);
    cylinder(d = inner_diameter, h = thickness + 2*eps, center = true);
}