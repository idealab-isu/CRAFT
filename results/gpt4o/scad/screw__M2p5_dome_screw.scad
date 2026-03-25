module dome_head_screw() {
    union() {
        // Screw head (dome shape)
        translate([0, 0, 10 - 1.6])
            sphere(d=5.35, $fn=64);
        
        // Screw shaft
        translate([0, 0, 0])
            cylinder(h=10, d=2.5, $fn=64);
    }
}

dome_head_screw();