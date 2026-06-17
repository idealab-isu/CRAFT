module iec_power_inlet() {
    difference() {
        // Main body
        cube([40, 32, 20], center = true);
        
        // Cutout for the inlet
        translate([-15, -10, -10])
            cube([30, 20, 20], center = false);
        
        // Holes for mounting
        translate([-18, 14, 0])
            cylinder(h = 20, r = 2, center = true, $fn = 64);
        translate([18, 14, 0])
            cylinder(h = 20, r = 2, center = true, $fn = 64);
    }
}

translate([0, 0, 10])
    iec_power_inlet();