$fn = 96;

// Target dimensions (mm)
shaft_diameter = 5.0;
shaft_length   = 10.0;   // under-head length
head_diameter  = 9.0;
head_height    = 2.4;

// Detail parameters
tip_length     = 1.6;    // tapered/pointed end length (included in shaft_length)
thread_pitch   = 1.0;    // visual thread pitch
thread_depth   = 0.35;   // radial depth of thread
thread_len     = shaft_length - tip_length; // threaded portion length
chamfer_h      = 0.5;    // small under-head transition

// Structural overlap to guarantee attachment (1–2mm as required)
overlap = 1.0;

module helical_thread(major_d, pitch, depth, len) {
    // Simple external thread approximation via helical triangular ridge
    turns = len / pitch;

    linear_extrude(
        height = len,
        twist = -360 * turns,
        slices = max(ceil(turns * 40), 60),
        convexity = 10
    )
        translate([major_d/2 - depth, 0, 0])
            polygon(points=[
                [0, -pitch*0.22],
                [depth, 0],
                [0,  pitch*0.22]
            ]);
}

module screw() {
    difference() {
        union() {
            // --- Shaft (core + threads + tip) ---
            union() {
                // Core cylinder for threaded length (minor diameter)
                cylinder(h = thread_len + overlap, d = shaft_diameter - 2*thread_depth, center = false);

                // Threads start at z=0 and run up to thread_len
                helical_thread(major_d = shaft_diameter, pitch = thread_pitch, depth = thread_depth, len = thread_len);

                // Pointed/tapered tip (overlaps into threaded section)
                translate([0, 0, thread_len - overlap])
                    cylinder(h = tip_length + overlap, d1 = shaft_diameter, d2 = 0.6, center = false);
            }

            // --- Under-head transition (must connect shaft to head) ---
            // Start slightly BELOW the shaft end so it overlaps the shaft by ~1mm
            translate([0, 0, shaft_length - chamfer_h - overlap])
                cylinder(h = chamfer_h + 2*overlap, d1 = shaft_diameter, d2 = head_diameter, center = false);

            // --- Head (overlaps into chamfer/shaft) ---
            // Start slightly BELOW shaft_length so it intersects the chamfer/shaft
            translate([0, 0, shaft_length - overlap])
                cylinder(h = head_height + overlap, d = head_diameter, center = false);
        }

        // Drive feature: Phillips-style cross recess on top of head
        recess_depth = min(1.2, head_height * 0.6);
        slot_w = 1.2;
        slot_l = head_diameter * 0.72;

        // Center the recess cuts so they reliably subtract from the head
        translate([-slot_l/2, -slot_w/2, shaft_length + head_height - recess_depth])
            union() {
                cube([slot_l, slot_w, recess_depth + overlap], center = false);
                translate([slot_l/2, slot_w/2, 0])
                    rotate([0, 0, 90])
                        translate([-slot_l/2, -slot_w/2, 0])
                            cube([slot_l, slot_w, recess_depth + overlap], center = false);
            }
    }
}

screw();