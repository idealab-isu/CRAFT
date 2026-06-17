$fn=96;

body_d = 0.8;
body_h = 4.7;

stem_d = 0.35;
stem_h = 1.6;

bushing_d = 0.55;
bushing_h = 0.5;

base_d = 1.2;
base_h = 0.6;

module toggle_switch() {
    union() {
        // Main cylindrical body
        cylinder(d=body_d, h=body_h);

        // Small bushing near top
        translate([0,0,body_h - bushing_h])
            cylinder(d=bushing_d, h=bushing_h);

        // Toggle stem protruding above body
        translate([0,0,body_h])
            cylinder(d=stem_d, h=stem_h);

        // Slight base flange
        translate([0,0,-base_h])
            cylinder(d=base_d, h=base_h);
    }
}

toggle_switch();