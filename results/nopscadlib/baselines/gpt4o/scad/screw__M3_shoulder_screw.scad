module screw() {
    union() {
        // Screw head
        translate([0, 0, 10])
            cylinder(h = 2.4, d = 7.0, $fn = 64);
        
        // Screw body
        cylinder(h = 10, d = 4.0, $fn = 64);
    }
}

screw();