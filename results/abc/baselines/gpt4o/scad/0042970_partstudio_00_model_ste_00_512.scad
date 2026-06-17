$fn=64;

module frame() {
    difference() {
        union() {
            // Main frame with rounded ends
            hull() {
                translate([-50, -90, 0]) circle(d=10);
                translate([50, -90, 0]) circle(d=10);
                translate([-50, 90, 0]) circle(d=10);
                translate([50, 90, 0]) circle(d=10);
            }
            // Mounting pads
            for (x = [-40, 40]) {
                for (y = [-80, 80]) {
                    translate([x, y, 0]) rotate([0, 0, 45]) mounting_pad();
                }
            }
        }
        // Central clearance
        translate([-40, -80, -1]) cube([80, 160, 2]);
    }
}

module mounting_pad() {
    union() {
        // Pad base
        cube([20, 10, 1], center=true);
        // Ribbing
        translate([-8, -4, 1]) cube([16, 1, 1]);
        translate([-8, 3, 1]) cube([16, 1, 1]);
        // Through-holes
        translate([-5, -2.5, -1]) cylinder(d=2, h=3);
        translate([5, -2.5, -1]) cylinder(d=2, h=3);
    }
}

translate([0, 0, -0.5]) frame();