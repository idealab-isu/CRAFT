module ball_bearing() {
    difference() {
        // Outer cylinder
        cylinder(d=8.0, h=3.0, $fn=64);
        // Inner bore
        translate([0, 0, -1])
            cylinder(d=3.0, h=5.0, $fn=64);
    }
}

ball_bearing();