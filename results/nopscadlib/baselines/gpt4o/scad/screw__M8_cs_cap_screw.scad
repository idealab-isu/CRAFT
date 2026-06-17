module socket_head_cap_screw() {
    union() {
        // Screw shaft
        cylinder(h=10, d=8, $fn=64);
        
        // Screw head
        translate([0, 0, 10])
            cylinder(h=5, d=16, $fn=64);
        
        // Hex socket
        translate([0, 0, 10])
            difference() {
                cylinder(h=5, d=8, $fn=64);
                translate([0, 0, 0.5])
                    cylinder(h=4, d=6, $fn=6);
            }
    }
}

socket_head_cap_screw();