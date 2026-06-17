module socket_head_cap_screw() {
    union() {
        // Screw head
        translate([0, 0, 10])
            cylinder(h=4.0, d=7.0, $fn=64);
        
        // Screw shaft
        cylinder(h=10, d=4.0, $fn=64);
        
        // Hex socket
        translate([0, 0, 10])
            cylinder(h=4.0, d=3.0, $fn=6);
    }
}

socket_head_cap_screw();