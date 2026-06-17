$fn = 96;

body_d = 7.0;
body_h = 13.6;

// Simple toggle switch approximation:
// - Cylindrical body
// - Small top collar
// - Toggle lever with rounded tip
// - Bottom solder-lug stub

module toggle_switch(body_d=7.0, body_h=13.6) {
    collar_h = 1.2;
    collar_d = body_d * 1.12;

    lever_d = 2.2;
    lever_h = 10.0;
    lever_tilt = 18; // degrees

    bottom_stub_d = body_d * 0.55;
    bottom_stub_h = 2.0;

    // Body
    union() {
        // Main body
        cylinder(d=body_d, h=body_h);

        // Top collar
        translate([0,0,body_h])
            cylinder(d=collar_d, h=collar_h);

        // Lever base boss
        translate([0,0,body_h + collar_h])
            cylinder(d=lever_d*1.6, h=1.2);

        // Lever (tilted)
        translate([0,0,body_h + collar_h + 1.2])
            rotate([0, lever_tilt, 0])
                union() {
                    cylinder(d=lever_d, h=lever_h);
                    translate([0,0,lever_h])
                        sphere(d=lever_d*1.05);
                }

        // Bottom stub (e.g., terminals area)
        translate([0,0,-bottom_stub_h])
            cylinder(d=bottom_stub_d, h=bottom_stub_h);
    }
}

toggle_switch(body_d, body_h);