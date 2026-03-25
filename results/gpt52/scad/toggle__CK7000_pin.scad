$fn=64;

body_d = 0.76;
body_r = body_d/2;
body_h = 4.7;

module toggle_switch(body_d=0.76, body_h=4.7) {
    body_r = body_d/2;

    lever_d = body_d*0.35;
    lever_h = body_h*0.55;
    lever_r = lever_d/2;

    cap_d = body_d*0.55;
    cap_h = body_h*0.10;
    cap_r = cap_d/2;

    base_d = body_d*1.25;
    base_h = body_h*0.12;
    base_r = base_d/2;

    union() {
        cylinder(h=body_h, r=body_r, center=true);

        translate([0,0, body_h/2 + base_h/2])
            cylinder(h=base_h, r=base_r, center=true);

        rotate([0,20,0])
            translate([0,0, body_h/2 + lever_h/2])
                cylinder(h=lever_h, r=lever_r, center=true);

        rotate([0,20,0])
            translate([0,0, body_h/2 + lever_h + cap_h/2])
                cylinder(h=cap_h, r=cap_r, center=true);
    }
}

toggle_switch(body_d=body_d, body_h=body_h);