module pan_head_screw() {
    union() {
        // Screw head
        translate([0, 0, 10])
            cylinder(h=2.2, d=6.7, $fn=64);
        
        // Screw shaft
        cylinder(h=10, d=3.5, $fn=64);
    }
}

pan_head_screw();