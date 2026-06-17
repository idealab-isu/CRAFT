module hex_head_screw() {
    union() {
        // Screw shaft
        cylinder(h=10, d=5, $fn=64);
        
        // Hexagonal head
        translate([0, 0, 10])
        cylinder(h=3.65, d=9.2, $fn=6);
    }
}

hex_head_screw();