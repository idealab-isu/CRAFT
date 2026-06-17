$fn = 64;

module t_slot_extrusion_3030(len=100, size=30) {
    // Simple 30x30 T-slot-like profile with 4 side slots + center bore.
    // All cuts are through the full length to ensure visible end-view features.
    eps = 0.2;

    half = size/2;

    // Slot geometry (approximate 3030)
    slot_depth = 7.0;          // how far the slot cuts in from the outer face
    slot_mouth = 6.2;          // opening at the outer face
    slot_inner = 11.0;         // wider cavity inside
    slot_inner_offset = 3.0;   // distance from outer face to start of inner widening

    // Center bore
    bore_r = 4.2;

    // Keep some wall thickness
    // (These values are chosen to avoid cutting through the outer walls/corners.)
    difference() {
        // Main body
        cube([size, size, len], center=true);

        // Center bore (through)
        cylinder(r=bore_r, h=len + 2*eps, center=true);

        // Four T-slots (through)
        for (a = [0, 90, 180, 270]) {
            rotate([0, 0, a]) {
                // Slot mouth: centered on +X face, cuts inward
                translate([half - slot_depth/2 + eps/2, 0, 0])
                    cube([slot_depth + eps, slot_mouth, len + 2*eps], center=true);

                // Inner cavity: starts a bit inside from the face, wider than mouth
                inner_depth = slot_depth - slot_inner_offset;
                translate([half - slot_inner_offset - inner_depth/2 + eps/2, 0, 0])
                    cube([inner_depth + eps, slot_inner, len + 2*eps], center=true);
            }
        }
    }
}

t_slot_extrusion_3030(len=100, size=30);