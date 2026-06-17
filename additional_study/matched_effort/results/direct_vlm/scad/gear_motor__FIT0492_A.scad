$fn = 128;

// Target dimensions: [motor_d, shaft_d, body_len, shaft_len]
motor_d  = 6;
shaft_d  = 5.5;
body_len = 14.7;
shaft_len= 12;

module gear_motor(motor_d=6, shaft_d=5.5, body_len=14.7, shaft_len=12) {

    // Small overlap to guarantee a single connected solid
    eps = 0.25;

    // Split body into gearbox + motor can (sum must equal body_len)
    gb_len = body_len * 0.42;
    m_len  = body_len - gb_len;

    // Gearbox block proportions (distinct from motor cylinder)
    gb_w = motor_d * 1.05;
    gb_h = motor_d * 0.82;

    // Front face features
    flange_t = max(0.6, motor_d * 0.14);
    flange_d = motor_d * 1.18;

    // Output boss at gearbox face
    boss_len = max(0.7, gb_len * 0.22);
    boss_d   = min(flange_d * 0.92, shaft_d * 1.35);

    // Shaft D-flat
    shaft_flat = shaft_d * 0.22;

    // Rear cap + small terminals to make it look like a motor
    cap_t = max(0.6, motor_d * 0.12);
    term_w = motor_d * 0.18;
    term_h = motor_d * 0.22;
    term_l = motor_d * 0.22;

    // Gear detail on front (teeth protrude outward)
    gear_h    = flange_t * 0.85;
    hub_d     = flange_d * 0.78;
    tooth_len = flange_d * 0.14;
    tooth_w   = flange_d * 0.11;
    teeth     = 12;
    overlap   = tooth_len * 0.35;

    union() {

        // --- Gearbox housing (rectangular) at front: z = 0 .. gb_len
        translate([0, 0, gb_len/2])
            cube([gb_w, gb_h, gb_len], center=true);

        // --- Front flange at very front: z = 0 .. flange_t
        translate([0, 0, flange_t/2])
            cylinder(d=flange_d, h=flange_t, center=true);

        // --- Gear teeth detail on front face (connected to flange)
        translate([0, 0, gear_h/2])
        union() {
            cylinder(d=hub_d, h=gear_h, center=true);
            for (i = [0:teeth-1])
                rotate([0, 0, i * 360/teeth])
                    translate([hub_d/2 + tooth_len/2 - overlap, 0, 0])
                        cube([tooth_len, tooth_w, gear_h], center=true);
        }

        // --- Output boss at gearbox face (connected), ends at z=body_len
        translate([0, 0, body_len - boss_len/2 + eps/2])
            cylinder(d=boss_d, h=boss_len + eps, center=true);

        // --- Motor can (cylindrical) behind gearbox: z = gb_len .. body_len
        translate([0, 0, gb_len + m_len/2 - eps/2])
            cylinder(d=motor_d, h=m_len + eps, center=true);

        // --- Rear cap ring (adds detail), at back end of motor can
        translate([0, 0, body_len - cap_t/2 + eps/2])
            cylinder(d=motor_d * 0.96, h=cap_t + eps, center=true);

        // --- Two small rear terminals (connected to rear cap)
        for (sx = [-1, 1]) {
            translate([sx*(motor_d*0.22), 0, body_len - cap_t + term_l/2])
                cube([term_w, term_h, term_l], center=true);
        }

        // --- Output shaft with D-flat, starting at z=body_len
        translate([0, 0, body_len + shaft_len/2 - eps/2])
        difference() {
            cylinder(d=shaft_d, h=shaft_len + eps, center=true);
            // Cut a flat along +X side
            translate([shaft_d/2 - shaft_flat/2, 0, 0])
                cube([shaft_flat, shaft_d*1.3, shaft_len + eps + 1], center=true);
        }
    }
}

gear_motor(motor_d, shaft_d, body_len, shaft_len);