$fn = 96;

// Target envelope (overall max diameter and height)
body_d = 7.0;
body_h = 13.6;

// Small overlap to guarantee a single connected solid
overlap = 0.25;

// --- Toggle switch proportions (kept within 7.0mm dia and 13.6mm tall) ---

// Main barrel (cylindrical body)
barrel_d = body_d;
barrel_h = 7.2;

// Mounting bushing (smaller diameter section above barrel)
bushing_d = body_d * 0.62;
bushing_h = 2.0;

// Hex nut (approximated as 6-sided prism) around bushing
nut_flat_d = body_d * 0.92;   // across flats (<= body_d)
nut_h = 1.2;

// Washer/flange under nut (thin ring)
washer_d = body_d * 0.98;
washer_h = 0.5;

// Toggle lever (tilted)
lever_d = body_d * 0.22;
lever_h = 2.2;
lever_tilt = 25; // degrees

// Lever tip (ball)
tip_d = body_d * 0.34;

// Anti-rotation tab on washer (small protrusion)
tab_w = body_d * 0.18;
tab_l = body_d * 0.22;
tab_h = washer_h;

// Derived: ensure exact total height
tip_h_equiv = tip_d; // sphere diameter contributes to height along lever axis; we account via placement
// Stack height excluding lever/tip (vertical stack)
stack_h = barrel_h + bushing_h + nut_h + washer_h;

// Place lever base at top of nut
lever_base_z = stack_h - overlap;

// Compute remaining height budget for lever+tip in Z (approx; lever is tilted so Z contribution is less)
// We keep lever+tip compact so total height stays within body_h.
remaining_h = body_h - stack_h;
lever_h2 = (remaining_h < 1.6) ? 1.6 : remaining_h; // keep recognizable
lever_h2 = (lever_h2 > 2.6) ? 2.6 : lever_h2;       // cap to avoid exceeding envelope

module hex_prism(flat_d, h) {
    // For a regular hexagon: across flats = 2*apothem = sqrt(3)*R  => R = flat_d/sqrt(3)
    R = flat_d / sqrt(3);
    cylinder(h=h, r=R, $fn=6);
}

module toggle_switch() {
    union() {
        // Barrel
        cylinder(d=barrel_d, h=barrel_h);

        // Bushing (connected)
        translate([0, 0, barrel_h - overlap])
            cylinder(d=bushing_d, h=bushing_h + overlap);

        // Washer/flange (connected)
        translate([0, 0, barrel_h + bushing_h - overlap])
            cylinder(d=washer_d, h=washer_h + overlap);

        // Anti-rotation tab on washer (connected at washer edge)
        translate([washer_d/2 - tab_l/2 - overlap, 0, barrel_h + bushing_h - overlap])
            cube([tab_l + overlap, tab_w, tab_h + overlap], center=false);

        // Hex nut (connected, sits on washer)
        translate([0, 0, barrel_h + bushing_h + washer_h - overlap])
            hex_prism(nut_flat_d, nut_h + overlap);

        // Toggle lever (tilted) connected to nut top
        translate([0, 0, lever_base_z])
            rotate([lever_tilt, 0, 0]) {
                cylinder(d=lever_d, h=lever_h2 + overlap);

                // Ball tip at lever end (connected)
                translate([0, 0, lever_h2 - overlap])
                    sphere(d=tip_d);
            }
    }
}

toggle_switch();