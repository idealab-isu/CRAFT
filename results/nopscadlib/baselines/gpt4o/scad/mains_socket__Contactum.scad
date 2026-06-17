module mains_socket() {
    difference() {
        // Base plate
        cube([60, 60, 5], center = true);
        
        // Cutouts for the socket holes
        translate([-15, 0, -2.5])
            cylinder(h = 10, d = 5, $fn = 64);
        translate([15, 0, -2.5])
            cylinder(h = 10, d = 5, $fn = 64);
        
        // Cutout for the earth pin
        translate([0, 15, -2.5])
            cylinder(h = 10, d = 7, $fn = 64);
    }
}

mains_socket();