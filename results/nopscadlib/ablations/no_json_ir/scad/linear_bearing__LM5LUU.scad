$fn = 128;

// Parameters (mm)
inner_bore_diameter = 5.0;
outer_diameter      = 10.0;
length              = 28.0;

// Small extra to guarantee clean boolean cuts
eps = 0.02;

module linear_bearing() {
    difference() {
        // Outer body (single connected solid)
        cylinder(h = length, d = outer_diameter, center = true);

        // Through bore (cut fully through with margin)
        cylinder(h = length + 2*eps, d = inner_bore_diameter, center = true);
    }
}

linear_bearing();