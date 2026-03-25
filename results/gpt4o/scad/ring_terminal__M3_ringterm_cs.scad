module ring_terminal() {
    difference() {
        union() {
            // Main body of the terminal
            translate([0, 0, -1])
                cylinder(h=2, r=10, $fn=64);
            // Connector part of the terminal
            translate([-5, 0, -1])
                cube([10, 20, 2], center=true);
        }
        // Hole in the ring
        translate([0, 0, -1.5])
            cylinder(h=3, r=5, $fn=64);
    }
}

ring_terminal();