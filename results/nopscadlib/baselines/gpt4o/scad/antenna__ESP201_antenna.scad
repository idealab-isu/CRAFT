module antenna() {
    union() {
        // Base of the antenna
        translate([0, 0, -5])
        cylinder(h = 10, r1 = 5, r2 = 5, $fn = 64);
        
        // Main rod of the antenna
        translate([0, 0, 5])
        cylinder(h = 100, r1 = 1, r2 = 1, $fn = 64);
        
        // Top sphere of the antenna
        translate([0, 0, 105])
        sphere(r = 3, $fn = 64);
    }
}

antenna();