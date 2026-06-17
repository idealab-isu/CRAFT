// Penny washer parameters (mm)
inner_diameter_mm = 3.0;   // required: 3.0mm hole
outer_diameter_mm = 12.0;  // required: 12.0mm OD
thickness_mm      = 0.8;   // required: 0.8mm thickness

// Small epsilon to guarantee clean subtraction
eps_mm = 0.2;

$fn = 128;

difference() {
    // Outer disk
    cylinder(d = outer_diameter_mm, h = thickness_mm, center = true);

    // Through hole (slightly taller to ensure it fully cuts)
    cylinder(d = inner_diameter_mm, h = thickness_mm + 2*eps_mm, center = true);
}