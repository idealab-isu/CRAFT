$fn = 96;

// 5.0mm through-hole LED (T-1 3/4), 5.9mm body height
// Approximate, renderable model

// Parameters (mm)
led_d = 5.0;          // body diameter
body_h = 5.9;         // cylindrical body height (excluding dome)
dome_h = 2.2;         // dome height (approx)
flange_d = 5.8;       // flange diameter (approx)
flange_h = 1.0;       // flange thickness (approx)

lead_d = 0.5;         // lead diameter (approx)
lead_pitch = 2.54;    // lead spacing (approx)
lead_len = 25;        // lead length below flange (approx)

flat_depth = 0.6;     // cathode flat depth (approx)
flat_width = 2.2;     // width of flat cut region (approx)

module led_body() {
    // Main body + dome + flange, with a small flat on one side
    difference() {
        union() {
            // Flange at base
            translate([0,0,0])
                cylinder(d=flange_d, h=flange_h);

            // Cylindrical body above flange
            translate([0,0,flange_h])
                cylinder(d=led_d, h=body_h);

            // Dome (spherical cap) above body
            translate([0,0,flange_h + body_h])
                intersection() {
                    sphere(d=led_d);
                    translate([0,0,0])
                        cylinder(d=led_d, h=dome_h);
                }
        }

        // Cathode flat: subtract a box from one side of the cylindrical portion
        translate([led_d/2 - flat_depth, -flat_width/2, flange_h])
            cube([flat_depth + 0.01, flat_width, body_h + 0.01], center=false);
    }
}

module leads() {
    // Two leads extending downward from underside of flange
    for (x = [-lead_pitch/2, lead_pitch/2]) {
        translate([x, 0, -lead_len])
            cylinder(d=lead_d, h=lead_len + 0.01);
    }
}

module led_5mm_th() {
    // Simple coloring for visualization
    color([0.85, 0.1, 0.1, 0.35]) led_body();
    color([0.75, 0.75, 0.78, 1.0]) leads();
}

led_5mm_th();