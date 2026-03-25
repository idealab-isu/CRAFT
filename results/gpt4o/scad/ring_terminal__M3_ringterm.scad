module ring_terminal() {
    difference() {
        union() {
            // Main body of the terminal
            translate([0, 0, -1])
                cylinder(h=2, r=5, $fn=64);
            // The ring part
            translate([0, 0, -1])
                cylinder(h=2, r=10, $fn=64);
            // The wire crimping section
            translate([0, 0, -1])
                cube([20, 10, 2], center=true);
        }
        // Hole in the ring
        translate([0, 0, -2])
            cylinder(h=4, r=3, $fn=64);
    }
}

ring_terminal();