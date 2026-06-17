$fn = 96;

// Toggle switch body envelope (requested)
body_d = 1.0;   // mm
body_h = 4.7;   // mm

// Toggle details (kept small but visible)
base_flange_d = 1.25;
base_flange_h = 0.25;

top_bushing_d = 0.85;
top_bushing_h = 0.55;

nut_flat_w = 1.15;   // across flats (hex)
nut_h = 0.28;

lever_d = 0.28;
lever_h = 1.55;

tip_d = 0.42;
tip_h = 0.35;

lever_tilt_deg = 18; // make it look like a toggle (not a straight post)

overlap = 0.05; // overlap to guarantee one connected solid

module hex_prism(af, h, center=false) {
    // Regular hex with given across-flats (af)
    r = af / sqrt(3); // circumradius for across-flats
    cylinder(r=r, h=h, $fn=6, center=center);
}

module toggle_switch() {
    union() {
        // Main cylindrical body (exact requested size)
        cylinder(d=body_d, h=body_h, center=false);

        // Base flange (connected)
        translate([0, 0, -base_flange_h + overlap])
            cylinder(d=base_flange_d, h=base_flange_h, center=false);

        // Top bushing (connected)
        translate([0, 0, body_h - overlap])
            cylinder(d=top_bushing_d, h=top_bushing_h, center=false);

        // Hex nut on top of bushing (connected)
        translate([0, 0, body_h + top_bushing_h - overlap])
            hex_prism(nut_flat_w, nut_h, center=false);

        // Toggle lever (tilted, connected at base)
        lever_z0 = body_h + top_bushing_h + nut_h - overlap;
        translate([0, 0, lever_z0])
            rotate([lever_tilt_deg, 0, 0])
                cylinder(d=lever_d, h=lever_h, center=false);

        // Lever tip (tilted, connected to lever end)
        translate([0, 0, lever_z0])
            rotate([lever_tilt_deg, 0, 0])
                translate([0, 0, lever_h - overlap])
                    cylinder(d=tip_d, h=tip_h, center=false);
    }
}

toggle_switch();