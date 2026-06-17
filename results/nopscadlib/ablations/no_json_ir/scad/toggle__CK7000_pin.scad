$fn = 96;

// Target overall dimensions (BODY ONLY)
body_d = 0.76;   // mm (max diameter of body housing)
body_h = 4.7;    // mm (height of body housing)

// Visible toggle details (kept small but readable)
collar_h = 0.28;
collar_d = body_d * 1.22;

lever_d = body_d * 0.30;
lever_h = body_h * 0.55;

tip_d = lever_d * 1.30;
tip_h = lever_h * 0.22;

// Small overlap to guarantee a single connected solid
overlap = 0.05;

// Subtle housing facet so orthographic views read as "toggle switch" not just a dot
housing_flat = body_d * 0.18;

module body_housing() {
    // Body stays within body_d envelope
    intersection() {
        cylinder(d = body_d, h = body_h, center = true);
        // Create a flat by intersecting with a slightly offset cube
        translate([housing_flat, 0, 0])
            cube([body_d, body_d * 1.35, body_h + 2], center = true);
    }
}

module collar() {
    // Collar sits on top of body and overlaps slightly into it
    translate([0, 0, body_h/2 - collar_h/2 + overlap])
        cylinder(d = collar_d, h = collar_h, center = true);
}

module lever_and_tip() {
    // Lever starts inside collar to ensure connectivity
    lever_base_z = body_h/2 + collar_h/2 - overlap;

    translate([0, 0, lever_base_z])
        cylinder(d = lever_d, h = lever_h, center = false);

    // Tip overlaps into lever
    translate([0, 0, lever_base_z + lever_h - overlap])
        cylinder(d = tip_d, h = tip_h, center = false);
}

module toggle_switch() {
    union() {
        body_housing();
        collar();
        lever_and_tip();
    }
}

toggle_switch();