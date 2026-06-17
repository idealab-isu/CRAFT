// Parameters for the penny washer
inner_hole_diameter = 10; // Diameter of the central hole
outer_diameter = 30;      // Outer diameter of the washer
thickness = 2;            // Thickness of the washer

// Module to create the penny washer
module penny_washer() {
    difference() {
        // Outer cylinder representing the washer body
        cylinder(h = thickness, d = outer_diameter, center = true);
        // Inner cylinder representing the central through-hole
        cylinder(h = thickness + 1, d = inner_hole_diameter, center = true);
    }
}

// Render the penny washer
penny_washer();