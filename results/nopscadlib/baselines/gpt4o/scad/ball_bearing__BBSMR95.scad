module ball_bearing() {
    difference() {
        // Outer cylinder
        cylinder(d=9.0, h=2.5, $fn=64);
        // Inner bore
        translate([0, 0, -1])
            cylinder(d=5.0, h=4.5, $fn=64);
    }
}

ball_bearing();