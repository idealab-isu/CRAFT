$fn = 96;

// Target overall dimensions (verify in orthographic views)
body_d = 0.76;   // main body diameter
body_h = 4.7;    // overall height including flange and lever tip

// Body details
base_flange_d = 1.05;
base_flange_h = 0.25;

// Toggle lever (external, recognizable)
lever_d = 0.22;
lever_len = 1.35;     // from pivot to tip along lever axis
lever_tilt = 25;      // degrees from vertical (tilt in +X)
pivot_ball_d = 0.34;

// Small overlap for watertight unions
eps = 0.02;

module toggle_switch() {
    body_r = body_d/2;

    // Main body cylinder sits on top of flange; total height remains body_h
    body_cyl_h = body_h - base_flange_h;

    // Place pivot near top so lever protrudes above body
    pivot_z = base_flange_h + body_cyl_h * 0.78;

    // Ensure lever tip does not exceed overall height
    // tip_z = pivot_z + lever_len*cos(lever_tilt)
    // If it would exceed, shorten lever_len automatically.
    max_lever_len = (body_h - pivot_z) / cos(lever_tilt);
    lever_len_eff = min(lever_len, max_lever_len);

    union() {
        // Base flange
        cylinder(d = base_flange_d, h = base_flange_h);

        // Main body cylinder (connected to flange)
        translate([0, 0, base_flange_h - eps])
            cylinder(d = body_d, h = body_cyl_h + eps);

        // External toggle lever assembly (connected at pivot)
        translate([0, 0, pivot_z]) {
            // Pivot ball (partly embedded visually, but unioned)
            sphere(d = pivot_ball_d);

            // Lever rod: rotate about Y so it tilts in XZ plane, then extend upward from pivot
            rotate([0, lever_tilt, 0])
                translate([0, 0, lever_len_eff/2 - eps])
                    cylinder(d = lever_d, h = lever_len_eff, center = true);

            // Small knob at lever tip for recognizability
            rotate([0, lever_tilt, 0])
                translate([0, 0, lever_len_eff - lever_d*0.2])
                    sphere(d = lever_d * 1.35);
        }

        // Simple bottom terminals (3 pins) to resemble a toggle switch; all connected to body
        pin_d = 0.14;
        pin_h = 0.55;
        pin_pitch = 0.22;

        for (x = [-pin_pitch, 0, pin_pitch])
            translate([x, 0, -pin_h + eps])
                cylinder(d = pin_d, h = pin_h + eps);
    }
}

toggle_switch();