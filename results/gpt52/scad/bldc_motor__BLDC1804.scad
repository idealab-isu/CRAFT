$fn=96;

stator_d = 23.0;
stator_h = 12.0;

motor_body_d = 27.0;
motor_body_h = 18.0;

shaft_d = 3.0;
shaft_h = 20.0;

front_boss_d = 10.0;
front_boss_h = 2.0;

mount_hole_d = 2.0;
mount_hole_r = 8.5;
mount_hole_count = 4;

wire_exit_w = 6.0;
wire_exit_t = 3.0;
wire_exit_h = 4.0;

module bolt_circle_holes(count, r, d, h, z0=0) {
    for (i = [0:count-1]) {
        rotate([0,0, i*360/count])
            translate([r,0,z0])
                cylinder(d=d, h=h, center=false);
    }
}

module motor_can(d, h) {
    cylinder(d=d, h=h, center=true);
}

module stator(d, h) {
    cylinder(d=d, h=h, center=true);
}

module shaft(d, h, z0) {
    translate([0,0,z0]) cylinder(d=d, h=h, center=true);
}

module front_boss(d, h, z0) {
    translate([0,0,z0]) cylinder(d=d, h=h, center=true);
}

module wire_exit(w, t, h, z0) {
    translate([motor_body_d/2 - t/2, 0, z0])
        cube([t, w, h], center=true);
}

module motor() {
    difference() {
        union() {
            motor_can(motor_body_d, motor_body_h);
            stator(stator_d, stator_h);
            front_boss(front_boss_d, front_boss_h, motor_body_h/2 - front_boss_h/2);
            shaft(shaft_d, shaft_h, motor_body_h/2 + shaft_h/2 - 2.0);
            wire_exit(wire_exit_w, wire_exit_t, wire_exit_h, -motor_body_h/2 + wire_exit_h/2 + 2.0);
        }

        translate([0,0, motor_body_h/2 - 2.0])
            bolt_circle_holes(mount_hole_count, mount_hole_r, mount_hole_d, 6.0, z0=0);

        translate([0,0, motor_body_h/2 - 1.0])
            cylinder(d=6.0, h=4.0, center=false);
    }
}

motor();