$fn = 96;

// Dimensions (mm)
body_d = 12.6;
body_h = 13.1;

// Simple toggle switch approximation
// - Cylindrical body
// - Small top bushing
// - Toggle lever

bushing_d = 8.0;
bushing_h = 2.5;

lever_d = 3.0;
lever_h = 12.0;

lever_tip_d = 4.2;
lever_tip_h = 2.0;

module toggle_switch() {
    union() {
        // Main body
        cylinder(d = body_d, h = body_h);

        // Top bushing
        translate([0, 0, body_h])
            cylinder(d = bushing_d, h = bushing_h);

        // Lever (slightly tilted)
        translate([0, 0, body_h + bushing_h])
            rotate([15, 0, 0])
                union() {
                    cylinder(d = lever_d, h = lever_h);
                    translate([0, 0, lever_h])
                        cylinder(d1 = lever_tip_d, d2 = lever_tip_d, h = lever_tip_h);
                }
    }
}

toggle_switch();