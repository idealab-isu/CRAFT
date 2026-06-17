$fn = 96;

dims = [12, 12, 6.5, 1.0]; // [body_x, body_y, body_z, shaft_d]

body_x = dims[0];
body_y = dims[1];
body_z = dims[2];
shaft_d = dims[3];

module potentiometer(body_x=12, body_y=12, body_z=6.5, shaft_d=1.0) {

    // --- Derived dimensions (kept proportional to given dims) ---
    edge_r   = min(0.35, min(body_x, body_y, body_z) * 0.06);

    // Shaft + bushing (top)
    shaft_h  = max(2.8, body_z * 0.55);
    bushing_d = max(shaft_d * 3.2, 2.6);
    bushing_h = max(1.0, body_z * 0.18);

    // Hex nut (top, around bushing)
    nut_flat = bushing_d * 1.35;
    nut_h    = max(0.9, bushing_h * 0.75);

    // Terminals (bottom)
    pin_d    = max(0.6, shaft_d * 0.7);
    pin_len  = max(2.6, body_z * 0.45);
    pin_pitch = body_x * 0.32;          // outer-to-outer spacing
    pin_y_off = body_y * 0.33;

    // Small bottom base plate to ensure ONE connected solid (pins connect to it)
    base_t   = max(0.7, body_z * 0.12);
    base_x   = body_x * 0.78;
    base_y   = body_y * 0.55;

    // Side notch (subtractive)
    notch_d  = min(2.2, body_y * 0.22);
    notch_len = body_x * 0.55;

    // --- Helpers ---
    module rounded_box(sz=[10,10,10], r=0.3) {
        minkowski() {
            cube([sz[0]-2*r, sz[1]-2*r, sz[2]-2*r], center=true);
            sphere(r=r);
        }
    }

    // --- Single connected solid ---
    union() {

        // Main body with side notch cut
        color([0.1, 0.35, 0.85])
        difference() {
            rounded_box([body_x, body_y, body_z], edge_r);

            // Side adjustment notch on +X face (clearly visible in left/right views)
            translate([ body_x/2 - notch_d/2 + 0.01, 0, 0 ])
                rotate([0,90,0])
                    cylinder(d=notch_d, h=notch_len, center=true);
        }

        // Bottom base plate (connects pins to body)
        color([0.1, 0.35, 0.85])
        translate([0, -pin_y_off*0.15, -body_z/2 - base_t/2 + 0.02])
            rounded_box([base_x, base_y, base_t], min(edge_r, base_t*0.35));

        // Top bushing + shaft (connected to body)
        color([0.85, 0.85, 0.85])
        translate([0, 0, body_z/2 - 0.02]) {
            // bushing
            cylinder(d=bushing_d, h=bushing_h + 0.02, center=false);

            // hex nut around bushing
            translate([0, 0, bushing_h - 0.02])
                cylinder(d=nut_flat, h=nut_h + 0.02, $fn=6, center=false);

            // shaft
            translate([0, 0, bushing_h + nut_h - 0.02])
                cylinder(d=shaft_d, h=shaft_h + 0.02, center=false);

            // screwdriver slot cut into top of shaft
            translate([0, 0, bushing_h + nut_h + shaft_h - 0.7])
            difference() {
                cylinder(d=shaft_d, h=0.7, center=false);
                translate([0, 0, 0.35])
                    cube([shaft_d*1.25, shaft_d*0.28, 1.2], center=true);
            }
        }

        // Terminals (3) connected to base plate
        color([0.9, 0.75, 0.2])
        for (i = [-1, 0, 1]) {
            translate([ i*(pin_pitch/2), -pin_y_off, -body_z/2 - base_t + 0.02 ])
                cylinder(d=pin_d, h=pin_len + base_t - 0.02, center=false);
        }
    }
}

potentiometer(body_x, body_y, body_z, shaft_d);