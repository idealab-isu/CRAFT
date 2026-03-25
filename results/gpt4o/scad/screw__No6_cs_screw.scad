module screw() {
    $fn = 64;
    union() {
        // Screw shaft
        cylinder(d = 3.5, h = 10, center = true);
        
        // Screw head
        translate([0, 0, 5])
            cylinder(d = 7.0, h = 2, center = true);
    }
}

screw();