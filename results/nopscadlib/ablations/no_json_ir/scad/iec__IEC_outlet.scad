$fn = 96;

// IEC power inlet module (approx. RS 811-7193 style)
// Overall front flange: 40 x 32 mm
// One connected solid with: front IEC C14-style opening + internal keying + rear body + rear terminals.

module rounded_rect_2d(w, h, r) {
    r2 = min(r, min(w, h)/2);
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(w/2 - r2), sy*(h/2 - r2)]) circle(r=r2);
    }
}

module iec_c14_opening_2d(w, h, r, notch_w, notch_h, notch_y) {
    // C14-ish: rounded rectangle with two small top corner notches (keying)
    difference() {
        rounded_rect_2d(w, h, r);
        for (sx = [-1, 1])
            translate([sx*(w/2 - notch_w/2), notch_y])
                square([notch_w, notch_h], center=true);
    }
}

module iec_inlet_module() {

    // --- Key dimensions (mm) ---
    flange_w = 40.0;
    flange_h = 32.0;
    flange_t = 2.2;

    // Main rear body (behind flange)
    body_w   = 30.0;
    body_h   = 22.0;
    body_d   = 20.0;

    // Small rear bump / housing feature
    bump_w = 16.0;
    bump_h = 12.0;
    bump_d = 7.0;

    // IEC C14-ish opening (front)
    opening_w = 27.0;
    opening_h = 20.0;
    opening_r = 2.0;

    // Keying notches (approx)
    notch_w = 4.0;
    notch_h = 3.0;
    notch_y = opening_h/2 - notch_h/2 - 1.2;

    // Inner cavity behind opening
    wall = 1.6;
    cavity_w = opening_w - 2.0;
    cavity_h = opening_h - 2.0;
    cavity_d = body_d - wall; // leave rear wall

    // Mount holes (flange)
    hole_r = 1.6;
    hole_edge_x = 3.5;
    hole_edge_y = 3.5;

    // Rear terminals (simple blades)
    term_w = 6.3;
    term_t = 0.8;
    term_l = 10.0;
    term_gap = 7.0; // L/N spacing
    term_y_earth = -4.0;

    // Z layout (front face at z=0, body extends negative)
    z_flange_center = flange_t/2;
    z_body_center   = -(body_d/2) + flange_t/2;
    z_bump_center   = -(flange_t + body_d) + bump_d/2;
    z_rear_face     = -(flange_t + body_d);
    z_term_center   = z_rear_face - term_l/2 + 0.8; // slight overlap into rear face

    // Internal pin cavities (female contacts) near front
    pin_slot_w = 5.2;
    pin_slot_h = 3.2;
    pin_slot_d = 9.0;
    pin_y = 3.6;
    pin_x_gap = 8.0;
    z_pin_center = flange_t - pin_slot_d/2 - 0.6; // starts just behind flange

    // Small internal "tongue" between L/N (common in IEC inlets)
    tongue_w = 2.2;
    tongue_h = 6.0;
    tongue_d = 6.0;
    z_tongue_center = flange_t - tongue_d/2 - 0.8;

    // Overlaps to guarantee connectivity
    ov = 0.6;

    difference() {
        union() {
            // Front flange
            translate([0, 0, z_flange_center])
                linear_extrude(height=flange_t, center=true)
                    rounded_rect_2d(flange_w, flange_h, 1.2);

            // Rear body (overlaps flange)
            translate([0, 0, z_body_center + ov/2])
                cube([body_w, body_h, body_d + ov], center=true);

            // Rear bump (overlaps body)
            translate([0, 0, z_bump_center - ov/2])
                cube([bump_w, bump_h, bump_d + ov], center=true);

            // Rear terminals (3 blades) connected to rear face with overlap
            for (sx = [-1, 1])
                translate([sx*term_gap/2, 0, z_term_center])
                    cube([term_w, term_t, term_l + ov], center=true);

            translate([0, term_y_earth, z_term_center])
                cube([term_w, term_t, term_l + ov], center=true);

            // Small external rear collar around terminals (keeps them visually "part of module")
            collar_w = 22.0;
            collar_h = 16.0;
            collar_d = 3.0;
            translate([0, 0, z_rear_face - collar_d/2 + ov/2])
                cube([collar_w, collar_h, collar_d + ov], center=true);
        }

        // IEC C14-ish opening through flange and slightly into body
        open_depth = flange_t + 2.0;
        translate([0, 0, z_flange_center])
            linear_extrude(height=open_depth, center=true)
                iec_c14_opening_2d(opening_w, opening_h, opening_r, notch_w, notch_h, notch_y);

        // Inner cavity behind opening (hollow into body)
        translate([0, 0, -(cavity_d/2) + flange_t - 0.2])
            cube([cavity_w, cavity_h, cavity_d + 0.4], center=true);

        // Female contact slots (3)
        for (sx = [-1, 1])
            translate([sx*pin_x_gap/2, pin_y, z_pin_center])
                cube([pin_slot_w, pin_slot_h, pin_slot_d], center=true);

        translate([0, term_y_earth, z_pin_center])
            cube([pin_slot_w, pin_slot_h, pin_slot_d], center=true);

        // Internal tongue relief (creates the characteristic center divider look)
        translate([0, pin_y - 1.0, z_tongue_center])
            cube([tongue_w, tongue_h, tongue_d], center=true);

        // Mounting holes (4 corners) through flange
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(flange_w/2 - hole_edge_x), sy*(flange_h/2 - hole_edge_y), z_flange_center])
                cylinder(h=flange_t + 2.0, r=hole_r, center=true);
    }
}

iec_inlet_module();