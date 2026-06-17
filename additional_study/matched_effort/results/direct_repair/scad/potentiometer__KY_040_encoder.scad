$fn = 96;

dims = [12, 12, 6.5, 1.0]; // [body_x, body_y, body_z, shaft_d]

body_x = dims[0];
body_y = dims[1];
body_z = dims[2];
shaft_d = dims[3];

module potentiometer(body_x=12, body_y=12, body_z=6.5, shaft_d=1.0) {
    // Heuristic proportions for a small trimmer potentiometer
    shaft_h = max(2.5, body_z * 0.55);
    collar_d = max(shaft_d * 2.2, 2.2);
    collar_h = max(0.8, body_z * 0.12);

    // Pins
    pin_d = 0.8;
    pin_len = 3.0;
    pin_spacing = body_x * 0.35;
    pin_y_offset = body_y * 0.25;

    // Body with slight edge rounding
    r = min(0.8, min(body_x, body_y) * 0.08);

    union() {
        // Main body (rounded rectangle prism)
        translate([0, 0, body_z/2])
        minkowski() {
            cube([body_x - 2*r, body_y - 2*r, body_z - 2*r], center=true);
            sphere(r=r);
        }

        // Top collar
        translate([0, 0, body_z + collar_h/2])
            cylinder(d=collar_d, h=collar_h, center=true);

        // Shaft
        translate([0, 0, body_z + collar_h + shaft_h/2])
            cylinder(d=shaft_d, h=shaft_h, center=true);

        // Small screwdriver slot on top of shaft (simple cut simulated by adding a thin bar)
        // (Since we can't "cut" in union, we approximate by adding a flat indicator)
        translate([0, 0, body_z + collar_h + shaft_h - 0.25])
            cube([shaft_d*1.2, shaft_d*0.25, 0.5], center=true);

        // Three pins on bottom
        for (i = [-1, 0, 1]) {
            translate([i*pin_spacing, -pin_y_offset, -pin_len/2])
                cylinder(d=pin_d, h=pin_len, center=true);
        }
    }
}

potentiometer(body_x, body_y, body_z, shaft_d);