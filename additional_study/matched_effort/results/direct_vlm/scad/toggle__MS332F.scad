$fn = 128;

// Toggle switch (recognizable, simplified)
// Requirement: body diameter = 12.6mm, body height = 13.1mm (body only; lever extends above)
// Model is ONE connected solid; all translate() values are formulas from dimensions.

body_d = 12.6;
body_h = 13.1;
body_r = body_d/2;

overlap = 0.25;

// --- Proportions (typical toggle switch features) ---
bushing_d   = body_d * 0.62;   // threaded bushing OD (visual)
bushing_h   = body_h * 0.22;

hex_flat_d  = body_d * 0.78;   // across flats (visual)
hex_h       = body_h * 0.12;

shoulder_d  = body_d * 0.70;   // small shoulder under hex
shoulder_h  = body_h * 0.06;

lever_d     = body_d * 0.18;   // lever thickness
lever_h     = body_h * 0.85;   // lever extends above body (common for toggles)
tip_d       = lever_d * 1.35;

terminal_w  = body_d * 0.18;
terminal_t  = body_d * 0.08;
terminal_h  = body_h * 0.28;
terminal_gap = body_d * 0.22;  // spacing between terminals
terminal_x  = body_d * 0.22;   // offset from center

// --- Derived Z positions (all formula-based) ---
z_body0 = 0;
z_body1 = z_body0 + body_h;

z_bushing0 = z_body1 - bushing_h;                 // bushing sits on top of body
z_hex0     = z_body1 - bushing_h - hex_h;         // hex nut below bushing
z_sh0      = z_hex0 - shoulder_h;                 // shoulder below hex

// Lever base sits on top of bushing
z_lever0 = z_body1 - overlap;                     // slight embed into bushing/body
z_lever1 = z_lever0 + lever_h;

// Terminals start at bottom of body and extend downward
z_term0 = z_body0 - terminal_h + overlap;         // embed into body
z_term1 = z_body0 + overlap;

module hex_prism(af, h) {
    // Regular hex with across-flats = af
    // For a regular hex: across-flats = 2 * apothem = sqrt(3) * R (circumradius)
    R = af / sqrt(3);
    cylinder(h=h, r=R, $fn=6);
}

module toggle_switch() {
    union() {
        // Main body (exact 12.6mm diameter, 13.1mm tall)
        cylinder(d=body_d, h=body_h);

        // Shoulder ring (visual step), connected with overlap
        translate([0, 0, z_sh0 - overlap])
            cylinder(d=shoulder_d, h=shoulder_h + 2*overlap);

        // Hex nut (visual), connected with overlap
        translate([0, 0, z_hex0 - overlap])
            hex_prism(hex_flat_d, hex_h + 2*overlap);

        // Threaded bushing (visual), connected with overlap
        translate([0, 0, z_bushing0 - overlap])
            cylinder(d=bushing_d, h=bushing_h + 2*overlap);

        // Lever (tilted), connected into bushing with overlap
        translate([0, 0, z_lever0])
            rotate([22, 0, 0])
                union() {
                    cylinder(d=lever_d, h=lever_h);
                    translate([0, 0, lever_h - tip_d*0.35])
                        sphere(d=tip_d);
                }

        // Terminals (3), connected to bottom of body with overlap
        for (i = [-1, 0, 1]) {
            translate([terminal_x, i*terminal_gap, (z_term0 + z_term1)/2])
                cube([terminal_w, terminal_t, (z_term1 - z_term0)], center=true);
        }
    }
}

toggle_switch();