module pan_head_screw() {
    union() {
        // Screw head
        translate([0, 0, 10])
            cylinder(h = 3.3, d = 7.8, $fn = 64);
        
        // Screw shaft
        cylinder(h = 10, d = 4.0, $fn = 64);
    }
}

pan_head_screw();