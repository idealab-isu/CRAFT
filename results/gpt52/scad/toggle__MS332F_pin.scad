$fn=64;

module toggle_switch(body_d=1.0, body_h=4.7) {
    shaft_d = body_d * 0.45;
    shaft_h = body_h * 0.35;
    cap_d   = body_d * 0.70;
    cap_h   = body_h * 0.10;

    union() {
        translate([0,0,-body_h/2])
            cylinder(d=body_d, h=body_h);

        translate([0,0, body_h/2])
            cylinder(d=shaft_d, h=shaft_h);

        translate([0,0, body_h/2 + shaft_h])
            cylinder(d=cap_d, h=cap_h);
    }
}

toggle_switch(1.0, 4.7);