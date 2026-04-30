$fn = 64;

module iec_inlet() {
    // Main body
    difference() {
        cube([27, 46.8, 16.5], center = true);
        translate([-13.5, -23.4, -16.5])
            cube([27, 46.8, 16.5]);
    }
    
    // Flange
    translate([-16.5, -28.5, -1.5])
        cube([33, 57, 3], center = true);
    
    // Mounting holes
    translate([-16.5, -20, 0])
        cylinder(h = 3, d = 3, center = true);
    translate([16.5, -20, 0])
        cylinder(h = 3, d = 3, center = true);
}

translate([0, 0, 1.5])
    iec_inlet();