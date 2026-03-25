module socket_head_cap_screw() {
    union() {
        // Screw shaft
        cylinder(h=10, d=5, $fn=64);
        
        // Screw head
        translate([0, 0, 10])
            cylinder(h=5, d=10, $fn=64);
        
        // Hex socket
        translate([0, 0, 10])
            difference() {
                cylinder(h=5, d=5, $fn=64);
                translate([0, 0, 0.5])
                    rotate([0, 0, 30])
                        cylinder(h=4, d=4, $fn=6);
            }
    }
}

socket_head_cap_screw();