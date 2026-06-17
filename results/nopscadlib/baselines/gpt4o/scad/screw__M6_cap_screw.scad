module socket_head_cap_screw() {
    union() {
        // Screw head
        translate([0, 0, 10])
            cylinder(h=6, d=10, $fn=64);
        
        // Screw shaft
        cylinder(h=10, d=6, $fn=64);
    }
}

socket_head_cap_screw();