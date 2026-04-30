$fn = 64;

module corner_bracket() {
    difference() {
        // Outer block
        cube([28, 28, 20], center = true);
        
        // Inner cutout
        translate([-14, -14, -10])
            cube([14, 14, 20]);
        
        // Hole for mounting
        translate([7, 7, 0])
            cylinder(h = 20, r = 3, center = true);
    }
}

translate([0, 0, 10])
    corner_bracket();