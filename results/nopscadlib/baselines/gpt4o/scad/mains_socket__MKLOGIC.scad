module mains_socket() {
    difference() {
        // Main body of the socket
        translate([-35, -35, 0])
        cube([70, 70, 5]);

        // Cutouts for the switches
        translate([-30, -30, -1])
        cube([15, 30, 6]);
        translate([15, -30, -1])
        cube([15, 30, 6]);

        // Cutouts for the plug holes
        translate([-10, 10, -1])
        cylinder(h=6, r=3, $fn=64);
        translate([10, 10, -1])
        cylinder(h=6, r=3, $fn=64);
        translate([0, -10, -1])
        cylinder(h=6, r=3, $fn=64);

        // Cutouts for the screw holes
        translate([-30, 30, -1])
        cylinder(h=6, r=2, $fn=64);
        translate([30, 30, -1])
        cylinder(h=6, r=2, $fn=64);
    }
}

mains_socket();