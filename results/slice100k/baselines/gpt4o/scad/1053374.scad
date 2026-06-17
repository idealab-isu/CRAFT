module bracket() {
    // Parameters
    lug_radius = 6.2;
    lug_thickness = 4;
    hole_radius = 2;
    arm_length = 10;
    arm_width = 4;
    arm_thickness = 2;
    pad_length = 5;
    pad_width = 4;
    pad_thickness = 2;
    pad_angle = 30;
    u_notch_width = 2;
    u_notch_depth = 1;

    // Lug with through-hole
    difference() {
        translate([0, 0, lug_thickness / 2])
            cylinder(r = lug_radius, h = lug_thickness, $fn = 64);
        translate([0, 0, -1])
            cylinder(r = hole_radius, h = lug_thickness + 2, $fn = 64);
    }

    // Arm
    translate([-arm_length / 2, 0, -arm_thickness / 2])
        cube([arm_length, arm_width, arm_thickness]);

    // U-shaped notch
    translate([-u_notch_depth, -u_notch_width / 2, -arm_thickness / 2])
        cube([u_notch_depth, u_notch_width, arm_thickness]);

    // End pad
    translate([arm_length / 2, 0, -pad_thickness / 2])
        rotate([0, pad_angle, 0])
        translate([0, 0, pad_thickness / 2])
        cube([pad_length, pad_width, pad_thickness]);
}

bracket();