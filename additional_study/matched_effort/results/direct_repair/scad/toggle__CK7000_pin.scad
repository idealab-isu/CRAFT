$fn = 96;

body_d = 0.76;
body_h = 4.7;

stem_d = 0.35;
stem_h = 1.6;

base_d = 1.2;
base_h = 0.35;

module toggle_switch() {
    union() {
        // Main cylindrical body
        cylinder(d = body_d, h = body_h);

        // Small base flange
        translate([0, 0, -base_h])
            cylinder(d = base_d, h = base_h);

        // Toggle stem on top
        translate([0, 0, body_h])
            cylinder(d = stem_d, h = stem_h);

        // Slight rounded cap on stem
        translate([0, 0, body_h + stem_h])
            sphere(d = stem_d);
    }
}

toggle_switch();