$fn = 64;

size = 30.0;     // mm
length = 100.0;  // mm

// Simple 30x30 aluminum extrusion-like profile (solid outer with central bore and 4 T-slots)
module extrusion_3030(len=100, s=30) {
    wall = 2.0;          // outer wall thickness
    bore_d = 6.0;        // central bore diameter
    slot_w = 6.0;        // slot opening width at surface
    slot_depth = 8.0;    // slot depth from surface inward
    slot_inner_w = 10.0; // widened cavity width inside
    slot_inner_depth = 12.0;

    difference() {
        // Outer body
        linear_extrude(height=len, center=false)
            square([s, s], center=true);

        // Central bore
        translate([0, 0, -0.1])
            cylinder(h=len+0.2, d=bore_d, center=false);

        // Hollow out interior slightly (keeps walls)
        translate([0, 0, -0.1])
            linear_extrude(height=len+0.2, center=false)
                offset(delta=-wall)
                    square([s, s], center=true);

        // Add back a cross web (so it's not fully hollow)
        // (We subtract hollow, then re-add webs by subtracting less: easiest is to subtract slots only;
        // so instead, we "unhollow" by leaving webs via not hollowing fully. We'll do it by adding material later.)
    }

    // Re-add internal cross webs
    // (Union with the hollowed body above)
    union() {
        // The hollowed body already exists from difference(); we need to include it:
        // In , we can't reference prior geometry, so we rebuild with union/difference properly.
    }
}

// Rebuild properly with union/difference
module extrusion_3030_full(len=100, s=30) {
    wall = 2.0;
    bore_d = 6.0;
    slot_w = 6.0;
    slot_depth = 8.0;
    slot_inner_w = 10.0;
    slot_inner_depth = 12.0;
    web = 2.0;

    difference() {
        union() {
            // Outer shell
            difference() {
                linear_extrude(height=len)
                    square([s, s], center=true);

                translate([0, 0, -0.1])
                    linear_extrude(height=len+0.2)
                        offset(delta=-wall)
                            square([s, s], center=true);
            }

            // Internal cross webs
            linear_extrude(height=len)
                union() {
                    square([web, s - 2*wall], center=true);
                    square([s - 2*wall, web], center=true);
                }
        }

        // Central bore
        translate([0, 0, -0.1])
            cylinder(h=len+0.2, d=bore_d);

        // Four T-slots
        for (a = [0, 90, 180, 270]) {
            rotate([0, 0, a]) {
                // Slot opening from surface inward
                translate([0, (s/2) - slot_depth/2, -0.1])
                    cube([slot_w, slot_depth, len+0.2], center=true);

                // Inner widened cavity
                translate([0, (s/2) - slot_inner_depth/2, -0.1])
                    cube([slot_inner_w, slot_inner_depth, len+0.2], center=true);
            }
        }
    }
}

extrusion_3030_full(length, size);