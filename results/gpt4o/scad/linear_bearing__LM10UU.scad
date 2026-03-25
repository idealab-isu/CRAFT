module linear_bearing() {
    difference() {
        // Outer cylinder
        cylinder(h=29.0, d=19.0, $fn=64);
        // Inner bore
        translate([0, 0, -1]) // Extend slightly to ensure clean cut
            cylinder(h=31.0, d=10.0, $fn=64);
    }
}

linear_bearing();