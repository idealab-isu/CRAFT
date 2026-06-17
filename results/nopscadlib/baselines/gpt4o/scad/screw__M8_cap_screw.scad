module socket_head_cap_screw() {
    union() {
        // Head of the screw
        translate([0, 0, 10])
            cylinder(h=8, d=13, $fn=64);
        
        // Shaft of the screw
        cylinder(h=10, d=8, $fn=64);
        
        // Hex socket
        translate([0, 0, 10])
            cylinder(h=8, d=6, $fn=6);
    }
}

socket_head_cap_screw();