module hex_head_screw() {
    union() {
        // Screw shaft
        cylinder(d=4.0, h=10, $fn=64);
        
        // Hex head
        translate([0, 0, 10])
            cylinder(d=8.1, h=2.925, $fn=6);
    }
}

hex_head_screw();