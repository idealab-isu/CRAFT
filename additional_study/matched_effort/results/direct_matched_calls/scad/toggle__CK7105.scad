$fn = 96;

body_d = 6.86;
body_h = 12.7;

stem_d = 3.0;
stem_h = 6.0;

bushing_d = 5.2;
bushing_h = 2.0;

lever_d = 2.0;
lever_h = 10.0;

tip_d = 3.0;
tip_h = 2.0;

base_flange_d = 7.6;
base_flange_h = 1.0;

module toggle_switch() {
    union() {
        // Main cylindrical body
        cylinder(d = body_d, h = body_h);

        // Small base flange
        translate([0, 0, -base_flange_h])
            cylinder(d = base_flange_d, h = base_flange_h);

        // Threaded/bushing section on top of body
        translate([0, 0, body_h])
            cylinder(d = bushing_d, h = bushing_h);

        // Stem above bushing
        translate([0, 0, body_h + bushing_h])
            cylinder(d = stem_d, h = stem_h);

        // Lever (toggle) above stem
        translate([0, 0, body_h + bushing_h + stem_h])
            cylinder(d = lever_d, h = lever_h);

        // Rounded-ish tip
        translate([0, 0, body_h + bushing_h + stem_h + lever_h])
            cylinder(d1 = lever_d, d2 = tip_d, h = tip_h);
    }
}

toggle_switch();