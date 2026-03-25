module radial_plate() {
    union() {
        // Central hub
        cylinder(h=0.01, r=0.01, $fn=64);
        
        // Arms with pads
        for (i = [0:5]) {
            rotate([0, 0, i * 60]) {
                translate([0.05, 0, 0]) {
                    arm_with_pad();
                }
            }
        }
    }
}

module arm_with_pad() {
    union() {
        // Arm
        translate([-0.025, -0.005, 0]) {
            cube([0.05, 0.01, 0.01]);
        }
        
        // Pad
        translate([0.025, -0.015, 0]) {
            scale([1, 1.5, 1]) {
                cylinder(h=0.01, r=0.015, $fn=64);
            }
        }
        
        // Holes in the pad
        for (x = [-0.01, 0.01]) {
            for (y = [-0.01, 0.01]) {
                translate([0.025 + x, y, 0]) {
                    rotate([0, 0, 45]) {
                        square_hole();
                    }
                }
            }
        }
    }
}

module square_hole() {
    difference() {
        scale([0.005, 0.005, 1]) {
            cube([1, 1, 0.02]);
        }
    }
}

radial_plate();