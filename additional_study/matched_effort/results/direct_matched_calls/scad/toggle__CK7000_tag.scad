$fn = 96;

body_d = 0.76;
body_h = 4.7;

stem_d = 0.28;
stem_h = 1.6;

base_flange_d = 1.05;
base_flange_h = 0.25;

module toggle_switch() {
    union() {
        // Main cylindrical body
        cylinder(d = body_d, h = body_h);

        // Small base flange
        translate([0, 0, 0])
            cylinder(d = base_flange_d, h = base_flange_h);

        // Toggle stem on top
        translate([0, 0, body_h])
            cylinder(d = stem_d, h = stem_h);

        // Rounded top cap
        translate([0, 0, body_h + stem_h])
            sphere(d = stem_d);
    }
}

toggle_switch();