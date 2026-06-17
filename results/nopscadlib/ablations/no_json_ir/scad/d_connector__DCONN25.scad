$fn = 64;

// One-piece, connected D-sub style connector (simplified DB9-like)
// Coordinate system: Front face at z=0, body extends to negative z, pins extend to positive z.

module d_sub_connector() {
    // Key dimensions (mm)
    flange_w = 60;
    flange_h = 30;
    flange_t = 2.5;

    shell_w  = 34;   // D opening width
    shell_h  = 12;   // D opening height
    shell_t  = 6;    // shell depth (front to back, into body)

    body_w   = 44;
    body_h   = 22;
    body_l   = 22;   // rear body length

    boot_w   = 36;
    boot_h   = 18;
    boot_l   = 14;

    // Mounting ears / jackscrew bosses
    boss_d   = 10;
    boss_h   = flange_t + 2; // slightly proud
    hole_d   = 3.2;
    boss_x   = flange_w/2 - boss_d/2 - 2;
    boss_y   = 0;

    // Pin array (DB9: 5 + 4)
    pin_d    = 1.2;
    pin_h    = 4.5;
    pin_pitch= 2.77;
    row_gap  = 2.84;

    // Ensure everything is one connected solid:
    // - Shell intersects flange and rear body
    // - Rear body intersects boot
    // - Pins intersect shell slightly
    union() {
        // Main solid with holes/cavity removed
        difference() {
            union() {
                // Flange plate
                translate([0, 0, -flange_t/2])
                    cube([flange_w, flange_h, flange_t], center=true);

                // D-shaped shell (outer)
                translate([0, 0, -shell_t/2])  // extends into negative z
                    linear_extrude(height=shell_t, center=true)
                        d_profile(shell_w, shell_h);

                // Rear body block (connected to shell)
                translate([0, 0, -(shell_t + body_l)/2 + 0.8]) // 0.8 overlap into shell
                    cube([body_w, body_h, body_l], center=true);

                // Strain relief boot (connected to rear body)
                translate([0, 0, -(shell_t + body_l + boot_l)/2 + 0.8]) // overlap into body
                    hull() {
                        translate([0, 0, 0])
                            cube([boot_w, boot_h, boot_l], center=true);
                        translate([0, 0, -boot_l*0.25])
                            cube([boot_w*0.85, boot_h*0.85, boot_l*0.7], center=true);
                    }

                // Jackscrew bosses (ears)
                for (sx = [-1, 1]) {
                    translate([sx*boss_x, boss_y, -boss_h/2])
                        cylinder(h=boss_h, d=boss_d, center=true);
                }
            }

            // Jackscrew through holes (cut through bosses + flange)
            for (sx = [-1, 1]) {
                translate([sx*boss_x, boss_y, -boss_h/2])
                    cylinder(h=boss_h + 2, d=hole_d, center=true);
            }

            // D-shaped cavity (inner opening) through shell
            inner_w = shell_w - 3.0;
            inner_h = shell_h - 3.0;
            translate([0, 0, -shell_t/2])
                linear_extrude(height=shell_t + 0.2, center=true)
                    d_profile(inner_w, inner_h);

            // Pin clearance cavity behind opening (slightly into body)
            translate([0, 0, -(shell_t*0.65)])
                cube([inner_w*0.9, inner_h*0.75, shell_t*0.9], center=true);
        }

        // Pins (protrude out of front face z=0, slightly embedded into shell for connectivity)
        translate([0, 0, pin_h/2 - 0.6])  // -0.6 embeds into shell
            pins_db9(pin_d, pin_h, pin_pitch, row_gap);
    }
}

// 2D D-profile: flat on top, rounded bottom (typical D-sub opening)
module d_profile(w, h) {
    // Construct as hull of a rectangle (top) and a circle (bottom)
    // so the top is flatter and bottom is rounded.
    hull() {
        // Top bar (flat)
        translate([0, h*0.18])
            square([w, h*0.64], center=true);

        // Bottom round
        translate([0, -h*0.18])
            circle(d=min(w, h)*0.95);
    }
}

// DB9 pin layout: 5 pins top row, 4 pins bottom row (staggered)
module pins_db9(pin_d, pin_h, pitch, row_gap) {
    // Top row: 5 pins centered
    for (i = [0:4]) {
        x = (i - 2) * pitch;
        y = row_gap/2;
        translate([x, y, 0])
            cylinder(h=pin_h, d=pin_d, center=true);
    }

    // Bottom row: 4 pins centered between top pins
    for (i = [0:3]) {
        x = (i - 1.5) * pitch;
        y = -row_gap/2;
        translate([x, y, 0])
            cylinder(h=pin_h, d=pin_d, center=true);
    }
}

d_sub_connector();