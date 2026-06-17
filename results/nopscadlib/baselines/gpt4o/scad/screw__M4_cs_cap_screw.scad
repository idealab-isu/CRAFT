module socket_head_cap_screw() {
    union() {
        // Screw shaft
        translate([0, 0, -10])
            cylinder(h=10, d=4, $fn=64);
        
        // Screw head
        translate([0, 0, 0])
            cylinder(h=2, d=8, $fn=64);
        
        // Hex socket
        translate([0, 0, 1])
            cylinder(h=1.5, d=3, $fn=6);
    }
}

socket_head_cap_screw();