module toggle_switch() {
    union() {
        // Body of the switch
        translate([0, 0, 2.35])
            cylinder(h=4.7, d=1.0, $fn=64);
        
        // Toggle part of the switch
        translate([0, 0, 4.7])
            cylinder(h=2.0, d=0.5, $fn=64);
    }
}

toggle_switch();