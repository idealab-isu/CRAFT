$fn = 96;

// Potentiometer parameters: [body_d, body_h, shaft_d, shaft_h]
p = [12, 11, 6, 0.5];

body_d  = p[0];
body_h  = p[1];
shaft_d = p[2];
shaft_h = p[3];

module potentiometer(body_d=12, body_h=11, shaft_d=6, shaft_h=0.5) {
    union() {
        // Main body
        cylinder(d=body_d, h=body_h);

        // Shaft (centered on top)
        translate([0,0,body_h])
            cylinder(d=shaft_d, h=shaft_h);

        // Small flat/tab to suggest orientation (subtle)
        translate([body_d*0.35, 0, body_h*0.25])
            cube([body_d*0.12, body_d*0.35, body_h*0.5], center=true);
    }
}

potentiometer(body_d, body_h, shaft_d, shaft_h);