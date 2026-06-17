// Parameters for the washer
inner_diameter = 10; // Inner hole diameter
outer_diameter = 20; // Outer diameter of the washer
thickness = 2;       // Thickness of the washer

// Washer body
module washer_body() {
    difference() {
        // Outer cylinder
        cylinder(h = thickness, d = outer_diameter, center = true);
        // Inner hole
        cylinder(h = thickness + 1, d = inner_diameter, center = true);
    }
}

// Render the washer
washer_body();