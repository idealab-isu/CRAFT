module toggle_switch() {
    union() {
        // Main body of the toggle switch
        cylinder(h=4.7, d=0.76, $fn=64);
        
        // Toggle lever
        translate([0, 0, 4.7])
            cylinder(h=2, d=0.5, $fn=64);
    }
}

toggle_switch();