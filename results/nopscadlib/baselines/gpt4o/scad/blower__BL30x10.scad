module centrifugal_blower_fan() {
    difference() {
        // Outer casing
        cube([30, 30, 10.1], center = true);
        
        // Inner cavity
        translate([0, 0, -5.05])
            cylinder(h = 10.1, r = 12, $fn = 64);
        
        // Air outlet
        translate([15, 0, -5.05])
            cube([5, 10, 10.1], center = true);
        
        // Fan blades
        for (i = [0:5]) {
            rotate([0, 0, i * 60])
                translate([0, 0, -5.05])
                    rotate([0, 0, 30])
                        translate([6, 0, 0])
                            cube([12, 2, 10.1], center = true);
        }
    }
}

centrifugal_blower_fan();