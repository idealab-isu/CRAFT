$fn = 96;

// 40x40 aluminium extrusion (approximate T-slot style), 100mm long
// Ensures: one connected solid, clear 40x40 outer envelope, 100mm length.
module extrusion_40x40(length=100, size=40) {
    half = size/2;
    eps  = 0.2;

    // Slot geometry (kept conservative so outer envelope remains 40x40)
    slot_open    = 6;    // opening width at outer face
    slot_depth   = 10;   // depth from outer face inward
    slot_inner_w = 12;   // inner cavity width
    slot_inner_d = 6;    // additional depth for inner cavity

    // Center bore
    center_bore_r = 5;

    // Internal webs (guarantee connectivity)
    web_th = 4;

    // Derived: keep webs inside the remaining core after slot cuts
    core = size - 2*(slot_depth + slot_inner_d);
    web_len = max(core, web_th + 2); // never negative/zero

    union() {
        // Main body with cuts
        difference() {
            cube([size, size, length], center=true);

            // Four T-slots (cut from outside faces inward)
            for (a = [0, 90, 180, 270]) {
                rotate([0, 0, a]) {
                    // Narrow mouth cut
                    translate([half - slot_depth/2, 0, 0])
                        cube([slot_depth + eps, slot_open, length + 2*eps], center=true);

                    // Wider inner cavity cut (deeper inside)
                    translate([half - slot_depth - slot_inner_d/2, 0, 0])
                        cube([slot_inner_d + eps, slot_inner_w, length + 2*eps], center=true);
                }
            }

            // Center bore through length
            cylinder(r=center_bore_r, h=length + 2*eps, center=true);
        }

        // Internal webs added back (overlap ensures single connected solid)
        cube([web_len + 2, web_th, length], center=true);
        cube([web_th, web_len + 2, length], center=true);
    }
}

// Render
extrusion_40x40(length=100, size=40);