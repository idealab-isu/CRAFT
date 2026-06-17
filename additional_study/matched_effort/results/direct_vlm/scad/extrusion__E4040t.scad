$fn = 64;

// Parameters
size = 40.0;      // cross-section width/height (mm)
length = 100.0;   // extrusion length (mm)

// Simple 40x40 aluminum extrusion-like profile (approximation)
module extrusion_40x40_profile() {
    difference() {
        // Outer square
        square([size, size], center = true);

        // Central bore
        circle(d = 8.0);

        // T-slots (approximate) on each face
        for (a = [0, 90, 180, 270]) {
            rotate(a) translate([size/2 - 6.0, 0]) {
                // Slot opening at the face
                square([4.0, 12.0], center = true);
                // Wider internal cavity
                translate([-4.0, 0]) square([10.0, 18.0], center = true);
            }
        }

        // Corner relief pockets (approximate)
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*(size/2 - 7.0), sy*(size/2 - 7.0)])
                circle(d = 10.0);
        }
    }
}

linear_extrude(height = length, center = false, convexity = 10)
    extrusion_40x40_profile();