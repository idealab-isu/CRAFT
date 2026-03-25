module dome_head_screw() {
    union() {
        // Screw head
        translate([0, 0, 1.3])
            sphere(d=3.5, $fn=64);
        
        // Screw head base
        cylinder(h=1.3, d=3.5, $fn=64);
        
        // Screw shaft
        translate([0, 0, -10])
            cylinder(h=10, d=2.0, $fn=64);
    }
}

dome_head_screw();