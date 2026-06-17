$fn=64;

body_d = 0.8;
body_h = 4.7;

bushing_d = 1.2;
bushing_h = 0.6;

lever_d = 0.35;
lever_h = 2.2;

tip_d = 0.55;
tip_h = 0.5;

base_d = 1.6;
base_h = 0.5;

module toggle_switch() {
    union() {
        translate([0,0,-(body_h/2 + base_h)])
            cylinder(d=base_d, h=base_h, center=false);

        translate([0,0,-body_h/2])
            cylinder(d=body_d, h=body_h, center=false);

        translate([0,0,body_h/2 - bushing_h])
            cylinder(d=bushing_d, h=bushing_h, center=false);

        translate([0,0,body_h/2])
            cylinder(d=lever_d, h=lever_h, center=false);

        translate([0,0,body_h/2 + lever_h])
            cylinder(d1=tip_d, d2=tip_d*0.85, h=tip_h, center=false);
    }
}

toggle_switch();