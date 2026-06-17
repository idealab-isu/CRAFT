module ball_bearing() {
    difference() {
        // Outer cylinder
        cylinder(h=2.5, d=8.0, $fn=64);
        // Inner bore
        translate([0, 0, -1])
            cylinder(h=4.5, d=5.0, $fn=64);
    }
}

ball_bearing();