$fn=96;

// Dimensions (mm)
body_d = 7.0;
body_r = body_d/2;
body_h = 13.6;

// Simple toggle proportions (approximate)
bushing_h = 2.2;
bushing_d = 8.2;

nut_h = 1.6;
nut_flat_d = 9.6; // across flats (approx)

washer_h = 0.6;
washer_d = 9.0;

lever_d = 2.2;
lever_h = 10.0;
tip_d = 3.2;
tip_h = 2.2;

base_flange_h = 1.2;
base_flange_d = 9.0;

module hex_prism(af=9.6, h=1.6){
    // Regular hex with across-flats = af
    // For a regular hex, across-flats = 2*R*cos(30) => R = af/(2*cos30)
    R = af/(2*cos(30));
    cylinder(h=h, r=R, $fn=6);
}

module toggle_switch(){
    union(){
        // Main cylindrical body
        color([0.15,0.15,0.15])
        translate([0,0,0])
            cylinder(h=body_h, r=body_r);

        // Base flange (slightly larger ring at bottom)
        color([0.12,0.12,0.12])
        translate([0,0,0])
            cylinder(h=base_flange_h, r=base_flange_d/2);

        // Threaded bushing (top collar)
        color([0.75,0.75,0.75])
        translate([0,0,body_h])
            cylinder(h=bushing_h, r=bushing_d/2);

        // Washer
        color([0.8,0.8,0.8])
        translate([0,0,body_h + bushing_h])
            difference(){
                cylinder(h=washer_h, r=washer_d/2);
                cylinder(h=washer_h+0.2, r=(bushing_d/2)*0.72);
            }

        // Hex nut
        color([0.7,0.7,0.7])
        translate([0,0,body_h + bushing_h + washer_h])
            hex_prism(af=nut_flat_d, h=nut_h);

        // Toggle lever
        color([0.85,0.85,0.85])
        translate([0,0,body_h + bushing_h + washer_h + nut_h])
            cylinder(h=lever_h, r=lever_d/2);

        // Lever tip
        color([0.9,0.9,0.9])
        translate([0,0,body_h + bushing_h + washer_h + nut_h + lever_h])
            cylinder(h=tip_h, r=tip_d/2);
    }
}

toggle_switch();