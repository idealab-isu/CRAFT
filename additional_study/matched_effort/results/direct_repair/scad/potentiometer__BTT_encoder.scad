$fn = 96;

dims = [12, 11, 6, 0.5]; // [body_d, body_h, shaft_d, pin_d]

body_d = dims[0];
body_h = dims[1];
shaft_d = dims[2];
pin_d  = dims[3];

module potentiometer(body_d=12, body_h=11, shaft_d=6, pin_d=0.5) {
    shaft_h = max(6, body_h*0.55);
    collar_d = max(shaft_d + 4, body_d*0.55);
    collar_h = max(1.2, body_h*0.12);

    pin_len = max(4, body_d*0.35);
    pin_pitch = max(2.54, body_d*0.22);
    pin_z = -pin_len;

    union() {
        // Main body
        color([0.15,0.15,0.15])
        cylinder(d=body_d, h=body_h);

        // Top collar
        color([0.75,0.75,0.75])
        translate([0,0,body_h])
            cylinder(d=collar_d, h=collar_h);

        // Shaft
        color([0.85,0.85,0.85])
        translate([0,0,body_h+collar_h])
            cylinder(d=shaft_d, h=shaft_h);

        // Flat on shaft (D-shaft)
        difference() {
            // nothing; just carve flat by subtracting from shaft volume
            // Implemented by adding a "flat cut" negative that overlaps shaft
            // (difference must wrap the shaft; so we re-add shaft with cut)
        }

        // Replace shaft with D-cut version
        color([0.85,0.85,0.85])
        translate([0,0,body_h+collar_h])
        difference() {
            cylinder(d=shaft_d, h=shaft_h);
            // flat cut
            translate([shaft_d*0.25, -shaft_d, -1])
                cube([shaft_d, 2*shaft_d, shaft_h+2], center=false);
        }

        // Pins (3)
        color([0.9,0.75,0.2])
        for (i=[-1,0,1]) {
            translate([i*pin_pitch, 0, pin_z])
                cylinder(d=pin_d, h=pin_len);
        }

        // Small anti-rotation tab on body side
        tab_w = body_d*0.18;
        tab_t = body_d*0.08;
        tab_h = body_h*0.55;
        color([0.2,0.2,0.2])
        translate([body_d/2 - tab_t*0.6, -tab_w/2, body_h*0.2])
            cube([tab_t, tab_w, tab_h], center=false);
    }
}

potentiometer(body_d, body_h, shaft_d, pin_d);