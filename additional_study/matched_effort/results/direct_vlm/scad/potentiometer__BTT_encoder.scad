$fn = 96;

dims = [12, 11, 6, 0.5]; // [body_d, body_h, shaft_d, shaft_h]

body_d = dims[0];
body_h = dims[1];
shaft_d = dims[2];
shaft_h = dims[3];

module potentiometer(body_d=12, body_h=11, shaft_d=6, shaft_h=0.5) {
    union() {
        // Main cylindrical body
        cylinder(d=body_d, h=body_h);

        // Shaft on top
        translate([0,0,body_h])
            cylinder(d=shaft_d, h=shaft_h);

        // Small flat/tab to suggest orientation
        translate([body_d*0.35, 0, body_h*0.35])
            rotate([0,90,0])
                cylinder(d=body_h*0.18, h=body_d*0.25);

        // Three pins at bottom
        pin_w = body_d*0.08;
        pin_t = body_d*0.06;
        pin_h = body_h*0.35;
        pin_spacing = body_d*0.18;

        for (i = [-1,0,1]) {
            translate([i*pin_spacing, -body_d*0.18, -pin_h])
                cube([pin_w, pin_t, pin_h], center=false);
        }
    }
}

potentiometer(body_d, body_h, shaft_d, shaft_h);