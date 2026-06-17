$fn = 96;

// Toggle switch: 0.8mm body diameter, 4.7mm tall (BODY ONLY)
body_d = 0.8;
body_h = 4.7;

// Visual switch details (kept within the 0.8mm body envelope)
collar_d = 0.78;     // slight step near top, still <= body_d
collar_h = 0.55;

cap_d = 0.72;        // small top cap
cap_h = 0.25;

// Toggle lever (extends above body; typical toggle look)
lever_d = 0.18;
lever_len = 1.35;
lever_ball_d = 0.28;
lever_tilt_deg = 22;

// Small overlap to guarantee watertight union
eps = 0.02;

module toggle_switch() {
    union() {
        // Body (housing): exactly 4.7mm tall, 0.8mm diameter
        cylinder(d=body_d, h=body_h);

        // Collar step near the top (connected, within body diameter)
        translate([0, 0, body_h - collar_h - eps])
            cylinder(d=collar_d, h=collar_h + eps);

        // Top cap (connected)
        translate([0, 0, body_h - cap_h - eps])
            cylinder(d=cap_d, h=cap_h + eps);

        // Lever: anchored at the top center of the body, tilted
        // Use center=true so we can place its base exactly at body_h with overlap.
        translate([0, 0, body_h + lever_len/2 - eps])
            rotate([lever_tilt_deg, 0, 0])
                cylinder(d=lever_d, h=lever_len, center=true);

        // Lever tip ball (connected to lever end)
        translate([0, 0, body_h + lever_len - eps])
            rotate([lever_tilt_deg, 0, 0])
                translate([0, 0, lever_len/2 - lever_ball_d*0.35])
                    sphere(d=lever_ball_d);
    }
}

toggle_switch();