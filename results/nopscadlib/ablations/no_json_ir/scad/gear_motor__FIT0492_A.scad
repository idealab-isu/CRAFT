module gear_motor_assembly() {
    gearbox_body();
    motor_can();
    output_shaft();
    shaft_boss();
    mounting_screw_bosses();
    mounting_screw_holes();
    electrical_tags();
}

module gearbox_body() {
    // Define the gearbox body dimensions and shape
    translate([0, 0, 0])
    cube([20, 20, 10], center = true);
}

module motor_can() {
    // Define the motor can dimensions and shape
    translate([0, 0, 10])
    cylinder(h = 20, r = 5, center = true);
}

module output_shaft() {
    // Define the output shaft dimensions and shape
    translate([0, 0, 20])
    cylinder(h = 30, r = 2, center = true);
}

module shaft_boss() {
    // Define the shaft boss dimensions and shape
    translate([0, 0, 15])
    cylinder(h = 5, r = 3, center = true);
}

module mounting_screw_bosses() {
    // Define the mounting screw bosses
    for (i = [0:3]) {
        rotate([0, 0, i * 90])
        translate([10, 0, 0])
        cylinder(h = 5, r = 1.5, center = true);
    }
}

module mounting_screw_holes() {
    // Define the mounting screw holes
    for (i = [0:3]) {
        rotate([0, 0, i * 90])
        translate([10, 0, 0])
        cylinder(h = 5, r = 1, center = true);
    }
}

module electrical_tags() {
    // Define the electrical tags
    translate([0, 0, 25])
    cube([2, 5, 1], center = true);
}

module gear_motor() {
    gear_motor_assembly();
}

gear_motor();