module socket_head_cap_screw() {
    // Head of the screw
    difference() {
        cylinder(h = 3.0, d = 5.5, $fn = 64);
        translate([0, 0, 1.5])
            cylinder(h = 3.0, d = 3.0, $fn = 64);
    }
    
    // Shaft of the screw
    translate([0, 0, -10])
        cylinder(h = 10, d = 3.0, $fn = 64);
}

socket_head_cap_screw();