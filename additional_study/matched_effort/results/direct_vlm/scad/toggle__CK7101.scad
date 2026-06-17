$fn = 96;

body_d = 6.86;
body_h = 12.7;

stem_d = 3.0;
stem_h = 6.0;

bushing_d = 5.2;
bushing_h = 2.0;

lever_d = 1.6;
lever_h = 10.0;

tip_d = 2.4;
tip_h = 2.0;

base_flange_d = 7.6;
base_flange_h = 1.2;

module toggle_switch() {
    union() {
        // Main cylindrical body
        color([0.15,0.15,0.15])
            cylinder(d=body_d, h=body_h);

        // Slight base flange
        color([0.12,0.12,0.12])
            cylinder(d=base_flange_d, h=base_flange_h);

        // Threaded/bushing section on top (simplified)
        translate([0,0,body_h])
            color([0.7,0.7,0.7])
                cylinder(d=bushing_d, h=bushing_h);

        // Stem
        translate([0,0,body_h + bushing_h])
            color([0.75,0.75,0.75])
                cylinder(d=stem_d, h=stem_h);

        // Lever (tilted)
        translate([0,0,body_h + bushing_h + stem_h])
            rotate([0,20,0])
                color([0.8,0.8,0.8])
                    cylinder(d=lever_d, h=lever_h);

        // Lever tip
        translate([0,0,body_h + bushing_h + stem_h])
            rotate([0,20,0])
                translate([0,0,lever_h])
                    color([0.85,0.85,0.85])
                        cylinder(d=tip_d, h=tip_h);
    }
}

toggle_switch();