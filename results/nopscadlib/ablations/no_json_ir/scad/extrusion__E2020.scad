$fn = 64;

// 20x20 aluminium extrusion-like profile (T-slot style), 100mm long
// Extrusion runs along Z so side views show the 100mm length.

module extrusion_2020(size=20, length=100, wall=2, slot_w=6, slot_depth=4, web=2, bore_d=5) {
    outer = size;
    half  = outer/2;

    // Keep parameters sane
    inner = max(outer - 2*wall, 0.1);
    slot_len = max(slot_depth, 0.1);
    web_w = max(web, 0.1);

    // Small overlap to avoid coincident faces (keeps one connected solid)
    eps = 0.02;

    linear_extrude(height=length, center=false, convexity=10)
        union() {
            // Outer shell with cavity, slots, and bore removed
            difference() {
                square([outer, outer], center=true);

                // Inner cavity
                square([inner, inner], center=true);

                // Four face slots (open to outside)
                translate([ half - slot_len/2 + eps, 0])
                    square([slot_len + 2*eps, slot_w], center=true);
                translate([-half + slot_len/2 - eps, 0])
                    square([slot_len + 2*eps, slot_w], center=true);
                translate([0,  half - slot_len/2 + eps])
                    square([slot_w, slot_len + 2*eps], center=true);
                translate([0, -half + slot_len/2 - eps])
                    square([slot_w, slot_len + 2*eps], center=true);

                // Center bore
                circle(d=bore_d);
            }

            // Internal webs (solid), slightly oversized to guarantee connection to shell
            square([inner + 2*eps, web_w], center=true);
            square([web_w, inner + 2*eps], center=true);
        }
}

extrusion_2020(size=20, length=100, wall=2, slot_w=6, slot_depth=4, web=2, bore_d=5);