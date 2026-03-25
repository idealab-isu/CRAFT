module beveled_rectangle(length, width, height, bevel) {
    difference() {
        cube([length, width, height], center=true);
        translate([-length/2, -width/2, 0])
            cube([length - 2*bevel, width - 2*bevel, height + 1], center=true);
    }
}

module cross_shape(arm_length, arm_width, arm_height, bevel, center_thickness) {
    union() {
        translate([0, 0, -arm_height/2])
            beveled_rectangle(arm_length, arm_width, arm_height, bevel);
        translate([0, 0, -arm_height/2])
            rotate([0, 0, 90])
            beveled_rectangle(arm_length, arm_width, arm_height, bevel);
        translate([0, 0, -center_thickness/2])
            cylinder(h=center_thickness, d=arm_width, $fn=64);
    }
}

cross_shape(100, 20, 5, 2, 7);