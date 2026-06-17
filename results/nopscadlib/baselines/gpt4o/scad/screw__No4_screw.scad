module pan_head_screw() {
    union() {
        // Screw head
        translate([0, 0, 10])
            cylinder(h=2.0, d=5.5, $fn=64);
        
        // Screw body
        cylinder(h=10, d=3.0, $fn=64);
    }
}

pan_head_screw();