module hex_head_screw() {
    union() {
        // Screw head
        translate([0, 0, 10])
            cylinder(h=5.65, d=15.0, $fn=6);
        
        // Screw body
        cylinder(h=10, d=8.0, $fn=64);
    }
}

hex_head_screw();