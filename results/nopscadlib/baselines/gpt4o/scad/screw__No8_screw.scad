module pan_head_screw() {
    union() {
        // Screw head
        translate([0, 0, 10])
            cylinder(h = 3.05, d = 8.2, $fn = 64);
        
        // Screw body
        cylinder(h = 10, d = 4.2, $fn = 64);
    }
}

pan_head_screw();