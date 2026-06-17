module iec_power_inlet() {
    difference() {
        // Main body
        cube([36, 27, 20], center = true);
        
        // Cutout for the fuse holder
        translate([-8, -13.5, -10])
            cube([16, 5, 20], center = false);
        
        // Cutout for the power socket
        translate([-12, 0, -10])
            cube([24, 27, 20], center = false);
    }
}

iec_power_inlet();