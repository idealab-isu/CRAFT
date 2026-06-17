module dome_head_screw() {
    union() {
        // Screw head
        translate([0, 0, 10])
            sphere(d=14, $fn=64);
        
        // Screw shaft
        translate([0, 0, 0])
            cylinder(h=10, d=8, $fn=64);
    }
}

dome_head_screw();