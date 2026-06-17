// Flat washer: 2.5mm ID, 5.9mm OD, 0.5mm thickness (single connected solid)

// Parameters
inner_diameter_mm = 2.5;
outer_diameter_mm = 5.9;
thickness_mm      = 0.5;

// Smoothness (prevents polygonal/octagon look)
$fn = 180;

module washer() {
    difference() {
        cylinder(d = outer_diameter_mm, h = thickness_mm, center = true);
        // Slightly taller cutter guarantees a clean through-hole
        cylinder(d = inner_diameter_mm, h = thickness_mm + 0.2, center = true);
    }
}

washer();