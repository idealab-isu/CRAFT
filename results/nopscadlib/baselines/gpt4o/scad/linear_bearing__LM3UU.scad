module linear_bearing() {
    difference() {
        // Outer cylinder
        cylinder(h=10.0, d=7.0, $fn=64);
        // Inner bore
        translate([0, 0, -1]) // Ensure the bore goes through completely
        cylinder(h=12.0, d=3.0, $fn=64);
    }
}

linear_bearing();