$fn = 96;

// Parameters (mm)
led_d = 10.0;          // LED body diameter
body_h = 11.0;         // LED body height (cylindrical portion)
dome_h = 4.0;          // domed top height
flange_d = 11.2;       // small flange at base
flange_h = 1.0;

lead_d = 0.6;          // lead diameter
lead_len = 25.0;       // lead length below body
lead_spacing = 2.54;   // typical lead spacing
lead_offset_y = 0.0;

flat_depth = 0.8;      // flat on one side (approx)

// Colors
body_col = [0.85, 0.1, 0.1, 0.35];
flange_col = [0.85, 0.1, 0.1, 0.45];
lead_col = [0.75, 0.75, 0.78, 1.0];

module led_body() {
    // Main body with a flat
    difference() {
        union() {
            // flange
            color(flange_col)
                cylinder(d=flange_d, h=flange_h);

            // cylindrical body
            color(body_col)
                translate([0,0,flange_h])
                    cylinder(d=led_d, h=body_h);

            // domed top (spherical cap)
            color(body_col)
                translate([0,0,flange_h + body_h])
                    intersection() {
                        sphere(d=led_d);
                        translate([0,0,0])
                            cylinder(d=led_d, h=dome_h);
                    }
        }

        // Flat side cut (D-shape)
        translate([led_d/2 - flat_depth, -led_d, -1])
            cube([led_d, 2*led_d, flange_h + body_h + dome_h + 2], center=false);
    }
}

module leads() {
    // Two leads extending downward from base
    for (sx = [-lead_spacing/2, lead_spacing/2]) {
        color(lead_col)
            translate([sx, lead_offset_y, -lead_len])
                cylinder(d=lead_d, h=lead_len);
    }
}

module led_10mm_through_hole() {
    union() {
        led_body();
        leads();
    }
}

led_10mm_through_hole();