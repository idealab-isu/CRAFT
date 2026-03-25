// Potentiometer: [12, 11, 6, 0.5]
// One connected solid, with cylindrical body + bushing + shaft + 3 terminals

type_0 = 12; //[6:24:1]
type_1 = 11; //[6:22:1]
type_2 = 6;  //[3:12:1]
type_3 = 0.5; //[0.25:1:0.05]

$fn = 64;

// ---- Derived dimensions (scaled from the 4-tuple) ----
body_d      = type_0;          // main can diameter
body_h      = type_1;          // main can height
shaft_d     = type_2;          // shaft diameter
pin_t       = type_3;          // terminal thickness

eps = max(0.2, pin_t*0.6);
overlap = max(0.4, pin_t*1.2);

// Bushing / boss
boss_d    = body_d * 0.55;
boss_h    = max(1.2, body_h * 0.12);

bushing_d = body_d * 0.42;
bushing_h = max(2.0, body_h * 0.22);

// Shaft
shaft_h   = max(8, body_h * 0.9);

// Terminals (3 pins)
pin_w     = max(pin_t*2.2, body_d*0.12);
pin_h     = max(3.0, body_h*0.35);
pin_pitch = body_d * 0.22;

// Small flat on body to suggest typical pot can
flat_depth = body_d * 0.10;

// ---- Geometry ----
module potentiometer() {
    union() {
        // Main cylindrical housing with a small flat (difference keeps it one solid via union at top level)
        difference() {
            cylinder(d=body_d, h=body_h, center=true);
            // Flat cut on one side (creates D-like can)
            translate([body_d/2 - flat_depth/2, 0, 0])
                cube([flat_depth, body_d*1.2, body_h*1.2], center=true);
        }

        // Boss (connected to top of body)
        translate([0, 0, body_h/2 + boss_h/2 - overlap])
            cylinder(d=boss_d, h=boss_h, center=true);

        // Threaded bushing (connected to boss)
        translate([0, 0, body_h/2 + boss_h - overlap + bushing_h/2 - overlap])
            cylinder(d=bushing_d, h=bushing_h, center=true);

        // Shaft (connected to bushing)
        translate([0, 0, body_h/2 + boss_h + bushing_h - 2*overlap + shaft_h/2 - overlap])
            cylinder(d=shaft_d, h=shaft_h, center=true);

        // Terminals/pins (connected to bottom of body)
        for (i = [-1, 0, 1]) {
            translate([i*pin_pitch, 0, -body_h/2 - pin_h/2 + overlap])
                cube([pin_w, pin_t, pin_h], center=true);
        }

        // Small base tab tying pins together (ensures robust connectivity)
        translate([0, 0, -body_h/2 - pin_t/2 + overlap])
            cube([pin_pitch*2 + pin_w, pin_t*1.2, pin_t], center=true);
    }
}

potentiometer();