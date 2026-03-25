module screw() {
    union() {
        // Screw head
        translate([0, 0, 10 - 2.4])
            cylinder(h=2.4, d=9.0, $fn=64);
        
        // Screw body
        cylinder(h=10, d=5.0, $fn=64);
    }
}

screw();