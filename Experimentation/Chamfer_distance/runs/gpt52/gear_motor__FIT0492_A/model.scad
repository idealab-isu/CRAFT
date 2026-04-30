$fn = 96;

module gearbox(d=37, h=24.5) {
    cylinder(d=d, h=h, center=true);
}

module motor_body(d=35.6, l=32) {
    cylinder(d=d, h=l, center=true);
}

module shaft(d=6, l=14.7) {
    cylinder(d=d, h=l, center=true);
}

module geared_dc_motor() {
    // Axis along Z, gearbox above motor, shaft above gearbox
    union() {
        // Motor body (rear)
        translate([0,0,-(24.5/2 + 32/2)])
            motor_body(d=35.6, l=32);

        // Gearbox (front)
        gearbox(d=37, h=24.5);

        // Shaft
        translate([0,0,(24.5/2 + 14.7/2)])
            shaft(d=6, l=14.7);
    }
}

geared_dc_motor();