$fn=64;

module led_5mm(body_d=5, body_h=8, flange_d=6, flange_h=1.2, dome_h=2.5, lead_d=0.6, lead_len=12, lead_spacing=2.54) {
    union() {
        translate([0,0,0])
            cylinder(d=flange_d, h=flange_h);

        translate([0,0,flange_h])
            cylinder(d=body_d, h=body_h);

        translate([0,0,flange_h+body_h])
            intersection() {
                translate([0,0,dome_h/2])
                    sphere(d=body_d);
                translate([-body_d, -body_d, 0])
                    cube([2*body_d, 2*body_d, dome_h]);
            }

        translate([0,0,flange_h+body_h-0.6])
            difference() {
                cylinder(d=body_d*0.98, h=0.6);
                translate([body_d*0.35,0,-0.1])
                    cylinder(d=body_d*0.12, h=0.8);
            }

        translate([ lead_spacing/2, 0, -lead_len])
            cylinder(d=lead_d, h=lead_len);

        translate([-lead_spacing/2, 0, -lead_len])
            cylinder(d=lead_d, h=lead_len);

        translate([ lead_spacing/2, 0, -lead_len-1.2])
            cylinder(d=lead_d*1.15, h=1.2);

        translate([-lead_spacing/2, 0, -lead_len-1.2])
            cylinder(d=lead_d*1.15, h=1.2);
    }
}

led_5mm();