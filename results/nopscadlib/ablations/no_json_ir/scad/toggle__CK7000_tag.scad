$fn = 96;

// Requested overall body size
body_d = 0.76;   // mm (main cylindrical body diameter)
body_h = 4.7;    // mm (main cylindrical body height)

// Small overlap to guarantee watertight union
ov = 0.05;

// Toggle lever (kept small but visible; connected to body)
lever_d = body_d * 0.22;
lever_h = body_h * 0.55;

// Collar at top of body (still within body diameter so body_d remains true)
collar_h = body_h * 0.12;
collar_d = body_d * 0.98;

// Lever tilt
tilt_deg = 18;

module toggle_switch() {
    union() {
        // Main body: exact requested diameter and height
        cylinder(d = body_d, h = body_h, center = true);

        // Subtle top collar (does not exceed body diameter)
        translate([0, 0, body_h/2 - collar_h/2 + ov/2])
            cylinder(d = collar_d, h = collar_h + ov, center = true);

        // Lever: attached at the top center, tilted
        translate([0, 0, body_h/2 - ov/2])
            rotate([tilt_deg, 0, 0])
                translate([0, 0, lever_h/2 - ov])
                    cylinder(d = lever_d, h = lever_h + ov, center = true);

        // Small knob at lever tip
        translate([0, 0, body_h/2 - ov/2])
            rotate([tilt_deg, 0, 0])
                translate([0, 0, lever_h - ov])
                    sphere(d = lever_d * 1.35);
    }
}

toggle_switch();