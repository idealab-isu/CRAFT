module hex_head_screw() {
    union() {
        // Screw shaft
        translate([0, 0, -10])
            cylinder(h=10, d=3.0, $fn=64);
        
        // Hex head
        translate([0, 0, 2.125/2])
            cylinder(h=2.125, d1=6.4, d2=6.4, $fn=6);
    }
}

hex_head_screw();