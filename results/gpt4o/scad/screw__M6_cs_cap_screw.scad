module socket_head_cap_screw() {
    union() {
        // Screw shaft
        translate([0, 0, -10])
            cylinder(h=10, d=6, $fn=64);
        
        // Screw head
        translate([0, 0, 0])
            cylinder(h=5, d=12, $fn=64);
        
        // Hex socket
        translate([0, 0, 2.5])
            rotate([0, 0, 0])
                cylinder(h=5, d=6, $fn=6);
    }
}

socket_head_cap_screw();