module toggle_switch() {
    union() {
        // Body of the switch
        translate([0, 0, 6.8])
            cylinder(h=13.6, d=7.0, $fn=64);
        
        // Toggle part of the switch
        translate([0, 0, 13.6])
            cylinder(h=5, d=3.0, $fn=64);
    }
}

toggle_switch();