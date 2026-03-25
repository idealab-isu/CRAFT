module stepped_block() {
    difference() {
        union() {
            translate([-0.05, -0.05, 0])
                cube([0.1, 0.1, 0.05]);
            translate([-0.05, -0.05, 0.05])
                cube([0.05, 0.1, 0.05]);
        }
        translate([-0.05, -0.025, 0])
            cube([0.01, 0.05, 0.05]);
        translate([0.04, -0.025, 0.05])
            cube([0.01, 0.05, 0.05]);
    }
}

stepped_block();