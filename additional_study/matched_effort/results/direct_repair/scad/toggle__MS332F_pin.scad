$fn = 96;

body_d = 1.0;
body_h = 4.7;

stem_d = 0.35;
stem_h = 1.6;

cap_d = 0.55;
cap_h = 0.35;

base_flange_d = 1.25;
base_flange_h = 0.25;

module toggle_switch() {
    union() {
        // Main cylindrical body
        cylinder(d=body_d, h=body_h);

        // Small base flange
        translate([0,0,0])
            cylinder(d=base_flange_d, h=base_flange_h);

        // Toggle stem (slightly offset/tilted look via small lateral shift)
        translate([0.08, 0, body_h - 0.2])
            cylinder(d=stem_d, h=stem_h);

        // Stem cap
        translate([0.08, 0, body_h - 0.2 + stem_h])
            cylinder(d=cap_d, h=cap_h);
    }
}

toggle_switch();