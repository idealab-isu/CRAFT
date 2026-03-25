module toggle_switch() {
    union() {
        // Body of the switch
        translate([0, 0, 2.35])
            cylinder(h=4.7, d=0.8, $fn=64);
        
        // Base of the switch
        translate([0, 0, 0])
            cylinder(h=0.5, d=1.2, $fn=64);
    }
}

toggle_switch();