module iec_power_inlet() {
    difference() {
        // Main body
        cube([36, 27, 20], center = true);
        
        // Cutout for fuse holder
        translate([-8, 0, -10])
            cube([16, 10, 20], center = true);
        
        // Cutout for power socket
        translate([0, 8, -10])
            cube([20, 10, 20], center = true);
        
        // Cutout for mounting holes
        translate([-15, -12, -10])
            cylinder(h = 20, r = 2, center = true, $fn = 64);
        translate([15, -12, -10])
            cylinder(h = 20, r = 2, center = true, $fn = 64);
    }
}

iec_power_inlet();