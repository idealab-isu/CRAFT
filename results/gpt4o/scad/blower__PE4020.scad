module centrifugal_blower_fan() {
    difference() {
        // Outer casing
        cube([40, 40, 20], center = true);
        
        // Inner cavity
        translate([0, 0, -10])
            cylinder(h = 20, r = 15, $fn = 64);
        
        // Air outlet
        translate([20, 0, -10])
            cube([20, 10, 20], center = true);
        
        // Fan blades
        for (i = [0 : 60 : 300]) {
            rotate([0, 0, i])
                translate([10, 0, 0])
                    cube([20, 2, 5], center = true);
        }
    }
}

centrifugal_blower_fan();