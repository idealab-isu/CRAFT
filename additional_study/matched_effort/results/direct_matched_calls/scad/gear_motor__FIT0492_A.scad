$fn = 96;

// Gear motor parameters: [6, 5.5, 14.7, 12]
shaft_d = 6;
shaft_len = 5.5;
gearbox_len = 14.7;
motor_d = 12;

// Derived proportions (simple, renderable approximation)
gearbox_d = motor_d * 0.85;
motor_len = motor_d * 1.6;

module gear_motor(shaft_d, shaft_len, gearbox_len, motor_d) {
    gearbox_d = motor_d * 0.85;
    motor_len = motor_d * 1.6;

    union() {
        // Motor can (rear)
        translate([0, 0, -motor_len])
            cylinder(d = motor_d, h = motor_len);

        // Gearbox (front)
        cylinder(d = gearbox_d, h = gearbox_len);

        // Output shaft
        translate([0, 0, gearbox_len])
            cylinder(d = shaft_d, h = shaft_len);

        // Small front flange lip
        translate([0, 0, 0])
            cylinder(d = gearbox_d * 1.05, h = gearbox_len * 0.08);

        // Rear cap lip
        translate([0, 0, -motor_len])
            cylinder(d = motor_d * 1.03, h = motor_len * 0.06);
    }
}

gear_motor(shaft_d, shaft_len, gearbox_len, motor_d);