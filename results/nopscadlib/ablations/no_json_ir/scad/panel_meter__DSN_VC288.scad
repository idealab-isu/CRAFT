$fn = 64;

// DSN-DC 100V 10A style panel meter (approximate)
// One connected solid, with front bezel + window recess + rear terminal block + side clips.

module rounded_box(size=[10,10,10], r=1, center=true) {
    // Minkowski rounded box (kept modest for performance)
    minkowski() {
        cube([size[0]-2*r, size[1]-2*r, size[2]-2*r], center=center);
        sphere(r=r);
    }
}

module panel_meter() {
    // ---- Key dimensions (mm) ----
    body_w = 48;
    body_h = 24;
    body_d = 28;

    bezel_w = 52;
    bezel_h = 27;
    bezel_t = 2.4;

    // Front window recess (not through-hole)
    win_w = 36;
    win_h = 16;
    win_recess = 1.2;

    // Small button bumps on front
    btn_r = 1.6;
    btn_h = 0.9;
    btn_y = bezel_h/2 - 4.2;
    btn_x = 10;

    // Side mounting clips (integrated)
    clip_w = 3.2;
    clip_h = 8.0;
    clip_d = 10.0;

    // Rear terminal block + screws
    term_w = 30;
    term_h = 10;
    term_d = 9;

    screw_r = 2.0;
    screw_h = 2.0;

    // Rear wire exit boss
    wire_w = 14;
    wire_h = 8;
    wire_d = 6;

    // Fillets
    body_r = 1.2;
    bezel_r = 1.0;
    term_r = 0.8;

    // ---- Derived positions (formulas, no arbitrary floats) ----
    // Coordinate system: Z+ is front, Z- is rear.
    body_front_z = body_d/2;
    body_back_z  = -body_d/2;

    bezel_center_z = body_front_z + bezel_t/2 - 0.6; // slight overlap into body
    clip_center_z  = body_front_z - clip_d/2 + 0.6;  // overlap into body

    term_center_z  = body_back_z - term_d/2 + 0.8;   // overlap into body
    wire_center_z  = body_back_z - wire_d/2 + 0.8;   // overlap into body

    // ---- Build as one connected solid ----
    difference() {
        union() {
            // Main body
            rounded_box([body_w, body_h, body_d], r=body_r, center=true);

            // Front bezel (slightly larger than body)
            translate([0, 0, bezel_center_z])
                rounded_box([bezel_w, bezel_h, bezel_t], r=bezel_r, center=true);

            // Side mounting clips (left/right), connected to body
            for (sx = [-1, 1]) {
                translate([sx*(body_w/2 + clip_w/2 - 0.8), 0, clip_center_z])
                    rounded_box([clip_w, clip_h, clip_d], r=0.6, center=true);
            }

            // Rear terminal block (connected)
            translate([0, 0, term_center_z])
                rounded_box([term_w, term_h, term_d], r=term_r, center=true);

            // Two screw bosses on terminal block (raised cylinders)
            for (sx = [-1, 1]) {
                translate([sx*(term_w/2 - 7), 0, term_center_z + term_d/2 + screw_h/2 - 0.4])
                    cylinder(h=screw_h, r=screw_r, center=true);
            }

            // Rear wire exit boss (connected)
            translate([0, -(term_h/2 + wire_h/2 - 0.8), wire_center_z])
                rounded_box([wire_w, wire_h, wire_d], r=0.8, center=true);

            // Front button bumps (connected to bezel)
            for (sx = [-1, 1]) {
                translate([sx*btn_x, btn_y, bezel_center_z + bezel_t/2 + btn_h/2 - 0.3])
                    cylinder(h=btn_h, r=btn_r, center=true);
            }
        }

        // ---- Subtractions (face features) ----

        // Display window recess on bezel (not through)
        translate([0, 0, bezel_center_z + bezel_t/2 - win_recess/2 + 0.01])
            rounded_box([win_w, win_h, win_recess + 0.02], r=0.8, center=true);

        // Inner "screen" pocket slightly deeper to suggest lens area
        translate([0, 0, bezel_center_z + bezel_t/2 - (win_recess + 0.6)/2 + 0.01])
            rounded_box([win_w-3, win_h-3, win_recess + 0.6 + 0.02], r=0.7, center=true);

        // Terminal screw slots (shallow cuts)
        for (sx = [-1, 1]) {
            translate([sx*(term_w/2 - 7), 0, term_center_z + term_d/2 + 0.2])
                rotate([0, 0, 90])
                    cube([1.2, 5.0, 1.2], center=true);
        }

        // Small rear wire notch (suggest cable exit)
        translate([0, -(term_h/2 + wire_h/2 - 0.8), wire_center_z - wire_d/2 + 1.2])
            cube([wire_w-4, wire_h-3, 2.4], center=true);
    }
}

panel_meter();