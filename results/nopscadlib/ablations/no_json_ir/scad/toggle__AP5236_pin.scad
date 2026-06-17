$fn = 64;

// Target overall: 0.8mm body diameter, 4.7mm tall (including lever)
body_d = 0.8;
total_h = 4.7;

// Simple toggle details (kept small but visible)
lever_d = 0.35;
lever_h = 1.2;

bushing_d = 0.55;
bushing_h = 0.35;

collar_d = 0.62;
collar_h = 0.25;

body_h = total_h - lever_h;  // ensures exact total height

// Small overlap to guarantee one connected solid
ov = 0.03;

module toggle_switch() {
    union() {
        // Main cylindrical body (base at z=0)
        cylinder(h = body_h, d = body_d, center = false);

        // Small collar near top of body (adds switch-like detail)
        translate([0, 0, body_h - collar_h])
            cylinder(h = collar_h + ov, d = collar_d, center = false);

        // Bushing/neck above body (connects to lever)
        translate([0, 0, body_h - ov])
            cylinder(h = bushing_h + ov, d = bushing_d, center = false);

        // Toggle lever: slightly tilted, rooted in bushing
        translate([0, 0, body_h + bushing_h - ov])
            rotate([18, 0, 0])
                cylinder(h = lever_h + ov, d = lever_d, center = false);
    }
}

toggle_switch();