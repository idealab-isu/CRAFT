$fn = 96;

// Target overall envelope for the switch body (excluding terminals):
// Body diameter = 0.76mm, total height = 4.7mm (from bottom of body to top of lever tip)
body_d = 0.76;
body_h = 4.7;

// Visual features (kept within the 0.76mm body diameter where applicable)
bushing_d = body_d;      // keep within requested body diameter
bushing_h = 0.55;

shoulder_d = body_d;     // keep within requested body diameter
shoulder_h = 0.35;

actuator_d = 0.22;
actuator_h = 1.35;
actuator_tilt_deg = 18;

tip_d = 0.34;
tip_h = 0.22;

// Terminals (extend below body; still one connected solid)
term_d = 0.16;
term_h = 0.55;
term_spacing = 0.22;     // center-to-center spacing
term_spread = term_spacing/2;

// Small overlap to guarantee manifold unions
ov = 0.02;

// Ensure total height from bottom of body to top of tip equals body_h
top_stack_h = shoulder_h + actuator_h + tip_h;
bushing_cyl_h = body_h - bushing_h - top_stack_h;
bushing_cyl_h = (bushing_cyl_h < 0) ? 0 : bushing_cyl_h;

module toggle_switch() {
    union() {
        // --- BODY (bottom at z=0) ---
        // Lower bushing section
        cylinder(d=bushing_d, h=bushing_h);

        // Main body cylinder
        translate([0, 0, bushing_h - ov])
            cylinder(d=body_d, h=bushing_cyl_h + ov);

        // Upper shoulder/collar (still within body diameter)
        translate([0, 0, bushing_h + bushing_cyl_h - ov])
            cylinder(d=shoulder_d, h=shoulder_h + ov);

        // --- ACTUATOR (tilted lever) ---
        // Lever starts at top of shoulder
        translate([0, 0, bushing_h + bushing_cyl_h + shoulder_h - ov])
            rotate([actuator_tilt_deg, 0, 0])
                cylinder(d=actuator_d, h=actuator_h + ov);

        // Tip at end of lever
        translate([0, 0, bushing_h + bushing_cyl_h + shoulder_h - ov])
            rotate([actuator_tilt_deg, 0, 0])
                translate([0, 0, actuator_h - ov])
                    cylinder(d=tip_d, h=tip_h + ov);

        // --- TERMINALS (below body) ---
        // Three pins connected to the bottom face of the body
        for (x = [-term_spacing, 0, term_spacing]) {
            translate([x, 0, -term_h + ov])
                cylinder(d=term_d, h=term_h + ov);
        }
    }
}

toggle_switch();