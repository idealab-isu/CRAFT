$fn=64;

motor_params = [6, 5.5, 14.7, 12]; // [shaft_d, shaft_len, body_len, body_d]

module d_shaft(d=6, l=5.5, flat_ratio=0.82) {
    flat_offset = d * (1 - flat_ratio) * 0.5;
    difference() {
        cylinder(d=d, h=l, center=false);
        translate([d/2 - flat_offset, 0, l/2])
            cube([d, d*2, l+0.2], center=true);
    }
}

module gear_motor(p=[6,5.5,14.7,12]) {
    shaft_d = p[0];
    shaft_len = p[1];
    body_len = p[2];
    body_d = p[3];

    union() {
        translate([0,0,-body_len/2])
            cylinder(d=body_d, h=body_len, center=true);

        translate([0,0, body_len/2])
            d_shaft(d=shaft_d, l=shaft_len, flat_ratio=0.82);

        translate([0,0,-body_len/2 - 1.2])
            cylinder(d=body_d*0.92, h=2.4, center=true);

        translate([0,0,-body_len/2 - 2.4])
            cylinder(d=body_d*0.55, h=2.4, center=true);
    }
}

gear_motor(motor_params);