module mains_socket() {
    difference() {
        // Main body of the socket
        cube([146, 86, 10], center = true);
        
        // Cutouts for the plug holes
        translate([-30, 0, 5])
            cylinder(h = 10, d = 5, $fn = 64);
        translate([30, 0, 5])
            cylinder(h = 10, d = 5, $fn = 64);
        translate([0, 20, 5])
            cylinder(h = 10, d = 5, $fn = 64);
        
        // Cutout for the screw holes
        translate([-60, 0, 5])
            cylinder(h = 10, d = 4, $fn = 64);
        translate([60, 0, 5])
            cylinder(h = 10, d = 4, $fn = 64);
    }
}

mains_socket();