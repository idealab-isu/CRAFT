$fn = 96;

// Target: potentiometer knob envelope ~ [12, 12, 6.5, 1.0]
body_width  = 12;
body_depth  = 12;
body_height = 6.5;
corner_radius_or_rounding = 1.0;

// Overlap to guarantee one connected solid (1–2mm as required)
overlap = 1.0;

// Knob proportions (short cylindrical knob)
knob_d = min(body_width, body_depth);     // 12
knob_r = knob_d/2;                        // 6
knob_h = body_height;                     // 6.5

// Subtle top cap and pointer ridge (kept within 12x12 footprint)
cap_h = 0.8;
cap_r = knob_r - 0.6;

pointer_w   = 2.0;
pointer_len = knob_r - 1.0;
pointer_h   = 0.9;

module potentiometer() {
    union() {
        // Main cylindrical knob (centered)
        cylinder(r=knob_r, h=knob_h, center=true);

        // Slightly rounded top cap (overlaps into knob by 'overlap')
        translate([0, 0, knob_h/2 - cap_h/2 - overlap/2])
            cylinder(r=cap_r, h=cap_h + overlap, center=true);

        // Small pointer ridge on the top face (overlaps into knob by 'overlap')
        translate([0,
                   knob_r - pointer_len/2 - 0.6,
                   knob_h/2 - pointer_h/2 - overlap/2])
            cube([pointer_w, pointer_len, pointer_h + overlap], center=true);
    }
}

// Missing part added: potentiometer (as a single connected solid)
potentiometer();