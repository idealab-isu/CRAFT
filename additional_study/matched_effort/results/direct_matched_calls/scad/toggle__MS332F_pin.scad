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

        // Toggle stem
        translate([0,0,body_h])
            cylinder(d=stem_d, h=stem_h);

        // Small cap on top of stem
        translate([0,0,body_h + stem_h])
            cylinder(d=cap_d, h=cap_h);
    }
}

toggle_switch();