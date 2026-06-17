module hex_head_screw() {
    union() {
        // Screw shaft
        cylinder(h=10, d=6, $fn=64);
        
        // Hex head
        translate([0, 0, 10])
            cylinder(h=4.15, d1=11.5, d2=11.5, $fn=6);
    }
}

hex_head_screw();