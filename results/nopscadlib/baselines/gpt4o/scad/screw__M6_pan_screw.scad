module pan_head_screw() {
    union() {
        // Screw head
        translate([0, 0, 10])
            cylinder(h = 4.75, d = 12.0, $fn = 64);
        
        // Screw body
        cylinder(h = 10, d = 6.0, $fn = 64);
    }
}

pan_head_screw();