$fn=64;

module led_3mm(body_d=3.0, body_h=3.15, flange_d=3.4, flange_h=0.35, dome_h=1.2, lead_d=0.5, lead_len=12, lead_pitch=2.54) {
    union() {
        // Body (cylindrical)
        translate([0,0,0])
            cylinder(d=body_d, h=body_h);

        // Flange at base
        translate([0,0,0])
            cylinder(d=flange_d, h=flange_h);

        // Dome top
        translate([0,0,body_h])
            scale([1,1,dome_h/(body_d/2)])
                sphere(d=body_d);

        // Leads
        for (x = [-lead_pitch/2, lead_pitch/2]) {
            translate([x,0,-lead_len])
                cylinder(d=lead_d, h=lead_len);
        }
    }
}

led_3mm();