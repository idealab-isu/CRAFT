$fn = 64;

// Potentiometer target envelope (approx): [W, D, H, shaft_d] = [12, 12, 6.5, 1.0]
module potentiometer(dim = [12,12,6.5,1.0]) {
    w = dim[0];
    d = dim[1];
    h = dim[2];
    shaft_d = dim[3];

    // Overlap to guarantee one connected solid (and avoid coplanar faces)
    ov = 0.25;

    // Main body
    body_w = w;
    body_d = d;
    body_h = h;

    // Z extents of body (centered)
    z_front =  body_h/2;
    z_back  = -body_h/2;

    // Front details (kept compact)
    flange_d = min(w, d) * 0.85;
    flange_h = 0.55;

    bushing_d = min(w, d) * 0.45;
    bushing_h = 0.75;

    shaft_len  = 1.35;
    shaft_flat = 0.18;

    // Terminals (3 pins) on back side
    pin_w = 0.55;
    pin_d = 0.9;
    pin_h = 1.2;
    pin_pitch = 2.0;

    // Anti-rotation tab on front
    tab_w = 1.2;
    tab_d = 0.8;
    tab_h = 0.5;

    // Helper: D-shaft as a solid (intersection avoids "difference inside union" preview issues)
    module d_shaft(diam, len, flat_depth) {
        intersection() {
            cylinder(d=diam, h=len, center=true);
            // Keep most of the cylinder, cut a flat by intersecting with a half-space box
            translate([-(diam/2 - flat_depth/2), 0, 0])
                cube([diam - flat_depth, diam*2, len*2], center=true);
        }
    }

    union() {
        // Main body
        cube([body_w, body_d, body_h], center=true);

        // Front flange
        translate([0, 0, z_front + flange_h/2 - ov])
            cylinder(d=flange_d, h=flange_h, center=true);

        // Front bushing
        translate([0, 0, z_front + flange_h - ov + bushing_h/2 - ov])
            cylinder(d=bushing_d, h=bushing_h, center=true);

        // Shaft (D-shaft)
        translate([0, 0, z_front + flange_h - ov + bushing_h - ov + shaft_len/2 - ov])
            d_shaft(shaft_d, shaft_len, shaft_flat);

        // Anti-rotation tab (front), connected to flange
        translate([0, flange_d/2 - tab_d/2 - ov, z_front + flange_h/2 - ov])
            cube([tab_w, tab_d, tab_h], center=true);

        // Back terminals (3 pins), connected to body with overlap
        for (i = [-1, 0, 1]) {
            translate([i*pin_pitch, 0, z_back - pin_h/2 + ov])
                cube([pin_w, pin_d, pin_h], center=true);
        }

        // Back boss / base for terminals, overlaps into body
        back_boss_w = min(w,d)*0.55;
        back_boss_d = min(w,d)*0.35;
        back_boss_h = 0.7;
        translate([0, 0, z_back - back_boss_h/2 + ov])
            cube([back_boss_w, back_boss_d, back_boss_h], center=true);
    }
}

potentiometer([12,12,6.5,1.0]);