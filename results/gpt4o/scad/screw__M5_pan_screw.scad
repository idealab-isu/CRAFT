module pan_head_screw() {
    // Screw head
    difference() {
        cylinder(h = 3.95, d = 10.0, $fn = 64);
        translate([0, 0, 1.0])
            cylinder(h = 2.95, d = 5.0, $fn = 64);
    }
    
    // Screw shaft
    translate([0, 0, -10])
        cylinder(h = 10, d = 5.0, $fn = 64);
}

pan_head_screw();