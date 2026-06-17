$fn = 96;

body_d = 6.86;
body_h = 12.7;

stem_d = 3.0;
stem_h = 6.0;

tip_d = 2.2;
tip_h = 2.5;

base_flange_d = 8.2;
base_flange_h = 1.2;

module toggle_switch() {
    union() {
        // Main cylindrical body
        cylinder(d = body_d, h = body_h);

        // Base flange (slightly larger ring at bottom)
        translate([0,0,0])
            cylinder(d = base_flange_d, h = base_flange_h);

        // Stem on top
        translate([0,0,body_h])
            cylinder(d = stem_d, h = stem_h);

        // Rounded-ish tip (simple taper)
        translate([0,0,body_h + stem_h])
            cylinder(d1 = stem_d, d2 = tip_d, h = tip_h);
    }
}

toggle_switch();