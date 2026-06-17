module socket_head_cap_screw() {
    union() {
        // Screw shaft
        cylinder(h=10, d=2.5, $fn=64);
        
        // Screw head
        translate([0, 0, 10])
            cylinder(h=2.5, d=4.5, $fn=64);
    }
}

socket_head_cap_screw();