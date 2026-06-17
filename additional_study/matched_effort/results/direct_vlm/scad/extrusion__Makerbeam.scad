$fn = 96;

// 10x10mm aluminum extrusion profile, 100mm long
size   = 10.0;     // mm (square cross-section)
length = 100.0;    // mm

// Profile parameters (derived from size)
wall        = size * 0.12;   // outer wall thickness
slot_w      = size * 0.22;   // T-slot opening width
slot_depth  = size * 0.28;   // depth from outer face to inner cavity
core_r      = size * 0.16;   // central bore radius
web_w       = size * 0.14;   // diagonal web thickness
eps         = 0.02;          // small overlap to avoid coincident faces

module extrusion10_profile_2d() {
    // Build as: (outer ring with slots removed) UNION (webs)
    // Ensures one connected solid and avoids accidental "all-subtracted" geometry.
    union() {
        // Outer ring with T-slot openings cut in
        difference() {
            // Outer square
            square([size, size], center=true);

            // Inner cavity (keeps outer wall)
            square([size - 2*wall, size - 2*wall], center=true);

            // Four T-slot channels (open to each face)
            for (a = [0:90:270]) {
                rotate(a)
                    translate([0, size/2 - slot_depth/2 + eps])
                        square([slot_w, slot_depth + 2*eps], center=true);
            }
        }

        // Diagonal webs to connect outer ring to core region
        for (a = [45:90:315]) {
            rotate(a)
                square([web_w, (size/2 - wall - core_r) * 2 + 2*eps], center=true);
        }
    }
}

// Extrude along Z; center it so orthographic views clearly show 10x10 cross-section
linear_extrude(height=length, center=true, convexity=10)
    extrusion10_profile_2d();