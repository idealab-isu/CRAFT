$fn=64;

size = 0.1;

body_x = 0.08;
body_y = 0.06;
body_z = 0.06;

tab_x = 0.02;
tab_y = 0.02;
tab_z = 0.02;

bore_d = 0.03;

boss_d = 0.03;
boss_len = 0.02;

module main_body() {
    union() {
        cube([body_x, body_y, body_z], center=true);

        translate([0, 0, (body_z/2 + tab_z/2)])
            cube([body_x*0.6, tab_y, tab_z], center=true);

        translate([0, 0, -(body_z/2 + tab_z/2)])
            cube([body_x*0.6, tab_y*0.7, tab_z], center=true);

        translate([body_x/2 + boss_len/2, 0, 0])
            rotate([0,90,0])
                cylinder(d=boss_d, h=boss_len, center=true);
    }
}

module through_bore() {
    rotate([0,90,0])
        cylinder(d=bore_d, h=size*2, center=true);
}

difference() {
    main_body();
    through_bore();
}