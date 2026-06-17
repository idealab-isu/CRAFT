$fn = 96;

// Dimensions (mm)
body_d = 12.6;
body_h = 13.1;

// Simple toggle switch approximation
// - Cylindrical body
// - Small top collar
// - Toggle lever with rounded tip
// - Bottom solder lug block (generic)

collar_d = 14.0;
collar_h = 1.6;

lever_d = 3.2;
lever_h = 14.0;
lever_tilt = 18; // degrees

tip_d = 4.2;

lug_w = 10.0;
lug_d = 6.0;
lug_h = 3.0;

module toggle_switch() {
    union() {
        // Main body
        cylinder(d=body_d, h=body_h);

        // Top collar (mounting bushing area)
        translate([0,0,body_h])
            cylinder(d=collar_d, h=collar_h);

        // Lever (tilted)
        translate([0,0,body_h + collar_h])
            rotate([lever_tilt,0,0])
                union() {
                    cylinder(d=lever_d, h=lever_h);
                    translate([0,0,lever_h])
                        sphere(d=tip_d);
                }

        // Bottom lug block (generic)
        translate([0,0,-lug_h])
            translate([-lug_w/2, -lug_d/2, 0])
                cube([lug_w, lug_d, lug_h]);
    }
}

toggle_switch();