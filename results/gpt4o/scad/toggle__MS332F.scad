module toggle_switch() {
    union() {
        // Main body of the switch
        translate([0, 0, 6.55])
            cylinder(h=13.1, d=12.6, $fn=64);
        
        // Base of the switch
        translate([0, 0, 0])
            cylinder(h=3, d=14, $fn=64);
        
        // Toggle lever
        translate([0, 0, 13.1])
            cylinder(h=10, d=4, $fn=64);
    }
}

toggle_switch();