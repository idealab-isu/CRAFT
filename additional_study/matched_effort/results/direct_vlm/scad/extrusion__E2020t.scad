$fn = 64;

// Parameters
size = 20.0;      // mm (square cross-section)
length = 100.0;   // mm

// Simple 20x20 aluminum extrusion-like profile (outer square with central bore and 4 T-slots)
module extrusion2020_profile() {
    difference() {
        // Outer body
        square([size, size], center = true);

        // Central bore
        circle(d = 5.0);

        // Four T-slots (approximation)
        for (a = [0, 90, 180, 270]) {
            rotate(a) translate([size/2 - 3.0, 0]) {
                // Slot opening at the face
                square([6.0, 2.2], center = true);
                // Inner cavity of the slot
                translate([-2.2, 0]) square([6.0, 6.8], center = true);
            }
        }

        // Corner reliefs (approximation of rounded/relieved corners)
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*(size/2 - 2.2), sy*(size/2 - 2.2)])
                circle(r = 1.2);
        }
    }
}

linear_extrude(height = length, center = false, convexity = 10)
    extrusion2020_profile();