$fn=64;

module toggle_switch(body_d=7.0, body_h=13.6, collar_d=9.0, collar_h=1.6, bushing_d=6.0, bushing_h=4.0, lever_d=2.2, lever_h=10.0, tip_d=3.2, tip_h=2.5) {
    union() {
        translate([0,0,-body_h/2])
            cylinder(d=body_d, h=body_h);

        translate([0,0,body_h/2 - collar_h])
            cylinder(d=collar_d, h=collar_h);

        translate([0,0,body_h/2])
            cylinder(d=bushing_d, h=bushing_h);

        translate([0,0,body_h/2 + bushing_h])
            cylinder(d=lever_d, h=lever_h);

        translate([0,0,body_h/2 + bushing_h + lever_h])
            cylinder(d1=lever_d, d2=tip_d, h=tip_h);
    }
}

toggle_switch();