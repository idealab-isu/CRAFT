module toggle_switch() {
    difference() {
        union() {
            // Main body of the toggle switch
            cylinder(h=4.7, d=0.76, $fn=64);
            // Top part of the toggle switch
            translate([0, 0, 4.7])
                sphere(d=0.76, $fn=64);
        }
        // Remove the bottom half of the sphere to make it a dome
        translate([0, 0, 4.7])
            cylinder(h=0.38, d=0.76, $fn=64);
    }
}

toggle_switch();