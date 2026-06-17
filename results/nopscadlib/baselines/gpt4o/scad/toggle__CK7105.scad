module toggle_switch() {
    union() {
        // Main cylindrical body
        cylinder(h=12.7, d=6.86, $fn=64);
        
        // Toggle lever
        translate([0, 0, 12.7])
            cylinder(h=5, d=3, $fn=64);
    }
}

toggle_switch();