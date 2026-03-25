module dome_head_screw() {
    // Screw head
    difference() {
        translate([0, 0, 2.2/2])
            sphere(d=7.6, $fn=64);
        translate([0, 0, -1])
            cylinder(h=2.2, d=7.6, $fn=64);
    }
    
    // Screw shaft
    translate([0, 0, -10])
        cylinder(h=10, d=4.0, $fn=64);
}

dome_head_screw();