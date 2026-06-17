module linear_bearing() {
    difference() {
        // Outer cylinder
        cylinder(h = 24.0, d = 15.0, $fn = 64);
        // Inner bore
        translate([0, 0, -1]) // Extend slightly to ensure clean cut
        cylinder(h = 26.0, d = 8.0, $fn = 64);
    }
}

linear_bearing();