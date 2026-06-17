$fn = 96;

body_d = 6.86;
body_h = 12.7;

stem_d = 3.0;
stem_h = 6.0;

bushing_d = 7.6;
bushing_h = 1.6;

nut_flat_d = 9.5;
nut_h = 1.8;

lever_d = 2.2;
lever_h = 12.0;

tip_d = 3.2;
tip_h = 2.5;

base_flange_d = 7.4;
base_flange_h = 1.0;

module hex_prism(flat_d, h) {
    // flat_d = distance across flats
    r = flat_d / (2 * cos(30));
    cylinder(h = h, r = r, $fn = 6);
}

module toggle_switch() {
    union() {
        // Main cylindrical body
        cylinder(h = body_h, d = body_d);

        // Small base flange
        translate([0,0,0])
            cylinder(h = base_flange_h, d = base_flange_d);

        // Threaded bushing area (simplified)
        translate([0,0,body_h - bushing_h])
            cylinder(h = bushing_h, d = bushing_d);

        // Hex nut on top (simplified)
        translate([0,0,body_h])
            hex_prism(nut_flat_d, nut_h);

        // Stem above nut
        translate([0,0,body_h + nut_h])
            cylinder(h = stem_h, d = stem_d);

        // Lever
        translate([0,0,body_h + nut_h + stem_h])
            cylinder(h = lever_h, d = lever_d);

        // Tip
        translate([0,0,body_h + nut_h + stem_h + lever_h])
            cylinder(h = tip_h, d1 = tip_d, d2 = tip_d * 0.9);
    }
}

toggle_switch();