$fn=64;

module led_5mm(body_d=5, body_h=8.7, flange_d=5.8, flange_h=1.2, dome_h=2.2, lead_d=0.6, lead_len=12, lead_spacing=2.54, lead_exposed=10) {
    module body() {
        union() {
            translate([0,0,0])
                cylinder(d=body_d, h=body_h - dome_h);
            translate([0,0,body_h - dome_h])
                intersection() {
                    sphere(d=body_d);
                    translate([0,0,0])
                        cylinder(d=body_d, h=dome_h);
                }
            translate([0,0,0])
                cylinder(d=flange_d, h=flange_h);
        }
    }

    module leads() {
        union() {
            translate([-lead_spacing/2,0,-lead_len])
                cylinder(d=lead_d, h=lead_len);
            translate([ lead_spacing/2,0,-lead_len])
                cylinder(d=lead_d, h=lead_len);
        }
    }

    module flat_cut() {
        translate([body_d*0.35,0,body_h*0.55])
            rotate([0,90,0])
                cylinder(d=body_d*1.2, h=body_d*1.2, center=true);
    }

    union() {
        difference() {
            body();
            flat_cut();
        }
        leads();
    }
}

led_5mm();