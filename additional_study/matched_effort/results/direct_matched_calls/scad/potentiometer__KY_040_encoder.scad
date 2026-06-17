$fn = 96;

dims = [12, 12, 6.5, 1.0]; // [body_x, body_y, body_z, shaft_d]

body_x = dims[0];
body_y = dims[1];
body_z = dims[2];
shaft_d = dims[3];

shaft_h = max(4, body_z * 0.8);
shaft_z0 = body_z;

module potentiometer(body_x, body_y, body_z, shaft_d, shaft_h) {
    union() {
        // Main body
        translate([-body_x/2, -body_y/2, 0])
            cube([body_x, body_y, body_z], center=false);

        // Top collar (small boss)
        translate([0, 0, body_z])
            cylinder(d = max(shaft_d * 2.2, 3), h = max(1.2, body_z * 0.18), center=false);

        // Shaft
        translate([0, 0, body_z + max(1.2, body_z * 0.18)])
            cylinder(d = shaft_d, h = shaft_h, center=false);

        // Three pins on one side
        pin_w = 0.7;
        pin_t = 0.4;
        pin_h = 3.0;
        pin_spacing = 2.54;
        pin_y = -body_y/2 - pin_t;

        for (i = [-1, 0, 1]) {
            translate([i * pin_spacing - pin_w/2, pin_y, 0])
                cube([pin_w, pin_t, pin_h], center=false);
        }
    }
}

potentiometer(body_x, body_y, body_z, shaft_d, shaft_h);