module l_bracket() {
    // Dimensions
    arm_length = 0.8;
    arm_width = 0.1;
    arm_thickness = 0.1;
    gusset_size = 0.1;
    thickened_end_length = 0.2;
    thickened_end_thickness = 0.2;

    // Horizontal arm
    translate([-arm_length/2, -arm_width/2, -arm_thickness/2])
        cube([arm_length, arm_width, arm_thickness]);

    // Vertical arm
    translate([-arm_width/2, -arm_length/2, -arm_thickness/2])
        cube([arm_width, arm_length, arm_thickness]);

    // Gusset
    translate([-gusset_size/2, -gusset_size/2, -arm_thickness/2])
        rotate([0, 0, 45])
        cube([gusset_size * sqrt(2), gusset_size, arm_thickness]);

    // Thickened end
    translate([arm_length/2 - thickened_end_length, -arm_width/2, -thickened_end_thickness/2])
        cube([thickened_end_length, arm_width, thickened_end_thickness]);
}

l_bracket();