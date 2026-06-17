$fn=64;

dims = [12, 12, 6.5, 1.0]; // [body_x, body_y, body_z, shaft_d]

module pot_body(bx, by, bz) {
    translate([0,0,bz/2])
        cube([bx, by, bz], center=true);
}

module pot_shaft(shaft_d, bz) {
    shaft_h = 8;
    translate([0,0,bz + shaft_h/2])
        cylinder(d=shaft_d, h=shaft_h, center=true);
}

module pot_pins(bx, by) {
    pin_w = 0.8;
    pin_t = 0.4;
    pin_h = 3.0;
    pin_spacing = 2.54;
    y_off = -by/2 - pin_t/2;
    for (i=[-1,0,1]) {
        translate([i*pin_spacing, y_off, -pin_h/2])
            cube([pin_w, pin_t, pin_h], center=true);
    }
}

module potentiometer(d) {
    bx = d[0];
    by = d[1];
    bz = d[2];
    shaft_d = d[3];

    union() {
        pot_body(bx, by, bz);
        pot_shaft(shaft_d, bz);
        pot_pins(bx, by);
    }
}

potentiometer(dims);