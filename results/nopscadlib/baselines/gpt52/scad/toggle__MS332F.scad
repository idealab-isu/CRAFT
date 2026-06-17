$fn=64;

body_d = 12.6;
body_h = 13.1;

bushing_d = 6.0;
bushing_h = 4.0;

lever_d = 3.0;
lever_h = 12.0;

tip_d = 4.2;
tip_h = 3.0;

base_flange_d = 14.0;
base_flange_h = 1.2;

module toggle_switch() {
    union() {
        translate([0,0,-body_h/2])
            cylinder(d=body_d, h=body_h);

        translate([0,0,body_h/2])
            cylinder(d=base_flange_d, h=base_flange_h);

        translate([0,0,body_h/2 + base_flange_h])
            cylinder(d=bushing_d, h=bushing_h);

        translate([0,0,body_h/2 + base_flange_h + bushing_h])
            cylinder(d=lever_d, h=lever_h);

        translate([0,0,body_h/2 + base_flange_h + bushing_h + lever_h])
            cylinder(d1=tip_d, d2=tip_d*0.85, h=tip_h);
    }
}

toggle_switch();