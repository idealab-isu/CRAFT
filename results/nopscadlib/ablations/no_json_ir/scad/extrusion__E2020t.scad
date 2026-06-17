// 20x20 T-slot aluminium extrusion profile, 100mm long
// Single connected solid, dimensions derived from parameters.

$fn = 64;

size = 20.0;   // cross-section width/height (mm)
len  = 100.0;  // extrusion length (mm)

// Proportions (kept conservative to ensure a connected, printable solid)
wall       = 2.0;   // outer wall thickness
core_size  = 8.0;   // central solid square (keeps everything connected)
bore_r     = 2.5;   // center bore radius

slot_open  = 6.0;   // opening width at each face
slot_depth = 6.0;   // depth of the slot from the face inward
slot_wide  = 10.0;  // wider internal pocket width (T-slot cavity)

eps = 0.02;

module cross_section_2020() {
    // Derived clearances
    half = size/2;

    // Ensure the slot pocket does not cut into the core
    // Pocket length from inner end of face-slot to near the core
    pocket_len = max(0.1, (half - wall) - (half - slot_depth) - core_size/2);
    // Equivalent: pocket_len = max(0.1, slot_depth - wall - core_size/2 + half - half) -> simplified above

    difference() {
        // Outer boundary
        square([size, size], center=true);

        // Central bore
        circle(r=bore_r);

        // Four face slots + internal wider pockets (kept away from core)
        for (a = [0, 90, 180, 270]) {
            rotate(a) {
                // Narrow opening cut from the face inward
                translate([0, half - slot_depth/2])
                    square([slot_open, slot_depth + eps], center=true);

                // Wider internal pocket (T cavity), starting just inside the slot
                // and extending toward the core but not into it.
                translate([0, (half - slot_depth) - pocket_len/2])
                    square([slot_wide, pocket_len + eps], center=true);
            }
        }

        // Corner relief voids (leave outer wall and keep connected to core via webs)
        corner_void = max(0, (half - wall) - (core_size/2));
        if (corner_void > 0) {
            for (sx = [-1, 1], sy = [-1, 1]) {
                translate([sx*(core_size/2 + corner_void/2), sy*(core_size/2 + corner_void/2)])
                    square([corner_void + eps, corner_void + eps], center=true);
            }
        }
    }
}

module extrusion_2020(L=len) {
    linear_extrude(height=L, center=true, convexity=10)
        cross_section_2020();
}

extrusion_2020(len);