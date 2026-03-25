// Parameters
rod_length = 26;    // mm
rod_diameter = 3;   // mm

// Ensure a smooth, truly circular cylinder in all views
$fn = 96;

// Geometry
module cylindrical_shaft(len, dia) {
    cylinder(h = len, d = dia, center = true);
}

// Final Model (single connected solid)
cylindrical_shaft(rod_length, rod_diameter);