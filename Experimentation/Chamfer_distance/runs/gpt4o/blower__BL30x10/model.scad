$fn = 64;

module blower_fan() {
    // Main housing
    difference() {
        cube([30, 30, 10.1], center = true);
        translate([0, 0, -5.05])
            cylinder(h = 10.1, d = 25, center = true);
    }
    
    // Rotor hub
    translate([0, 0, -5.05])
        cylinder(h = 10.1, d = 16, center = true);
    
    // Exit port
    translate([0, 15, -5.05])
        cube([21.2, 10, 10.1], center = true);
}

blower_fan();