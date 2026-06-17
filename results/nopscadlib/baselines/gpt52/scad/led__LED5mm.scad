$fn=96;

module led_5mm(body_d=5.0, body_h=5.9, flange_d=5.8, flange_h=1.0, dome_h=2.2, lead_d=0.5, lead_len=12.0, lead_pitch=2.54) {
    union() {
        // Body (cylindrical)
        translate([0,0,0])
            cylinder(d=body_d, h=body_h);

        // Flange at base
        translate([0,0,0])
            cylinder(d=flange_d, h=flange_h);

        // Dome (spherical cap)
        translate([0,0,body_h])
            intersection() {
                translate([0,0,-(body_d/2 - dome_h)])
                    sphere(d=body_d);
                cylinder(d=body_d, h=dome_h);
            }

        // Leads
        for (x = [-lead_pitch/2, lead_pitch/2]) {
            translate([x,0,-lead_len])
                cylinder(d=lead_d, h=lead_len);
        }
    }
}

translate([0,0,-5.9/2])
    led_5mm();