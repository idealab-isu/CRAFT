$fn = 64;

module motor_body() {
    difference() {
        cylinder(h = 8, d = 9, center = true);
        translate([0, 0, -4])
            cylinder(h = 15.5, d = 1, center = true);
    }
}

module base_plate() {
    cylinder(h = 1, d = 10, center = true);
}

module shaft() {
    translate([0, 0, 4])
        cylinder(h = 15.5, d = 1, center = true);
}

translate([0, 0, -4])
    motor_body();

translate([0, 0, -4.5])
    base_plate();

shaft();