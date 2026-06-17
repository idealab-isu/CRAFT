module linear_bearing() {
    difference() {
        // Outer cylinder
        cylinder(h=15.0, d=10.0, $fn=64);
        // Inner bore
        translate([0, 0, -1]) // Ensure the bore goes through completely
            cylinder(h=17.0, d=5.0, $fn=64);
    }
}

linear_bearing();