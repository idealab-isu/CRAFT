module dome_head_screw() {
    union() {
        // Screw head
        translate([0, 0, 10 - 1.65])
            sphere(d=5.7, $fn=64);
        
        // Screw shaft
        translate([0, 0, 0])
            cylinder(h=10, d=3.0, $fn=64);
    }
}

dome_head_screw();