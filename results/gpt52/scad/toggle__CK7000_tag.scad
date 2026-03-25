$fn=64;

body_d = 0.76;
body_r = body_d/2;
body_h = 4.7;

lever_d = 0.25;
lever_r = lever_d/2;
lever_h = 2.2;

cap_d = 0.55;
cap_r = cap_d/2;
cap_h = 0.35;

base_d = 1.2;
base_r = base_d/2;
base_h = 0.35;

module toggle_switch() {
    union() {
        translate([0,0,-body_h/2 + base_h/2])
            cylinder(h=base_h, r=base_r, center=true);

        cylinder(h=body_h, r=body_r, center=true);

        translate([0,0,body_h/2 + lever_h/2])
            cylinder(h=lever_h, r=lever_r, center=true);

        translate([0,0,body_h/2 + lever_h + cap_h/2])
            cylinder(h=cap_h, r=cap_r, center=true);
    }
}

toggle_switch();