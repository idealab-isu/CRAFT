module pan_head_screw() {
    union() {
        // Screw head
        translate([0, 0, 10 - 1.7])
            cylinder(h = 1.7, d = 4.7, $fn = 64);
        
        // Screw shaft
        translate([0, 0, 0])
            cylinder(h = 10, d = 2.5, $fn = 64);
    }
}

pan_head_screw();