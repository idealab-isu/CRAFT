$fn = 180;

// Target dimensions (mm)
outer_diameter = 26.0;
inner_diameter = 6.0;
thickness      = 1.5;

// Small extra height to guarantee clean subtraction
overlap = 0.2;

difference() {
    // Outer body
    cylinder(d = outer_diameter, h = thickness, center = true);

    // Through hole
    cylinder(d = inner_diameter, h = thickness + 2*overlap, center = true);
}