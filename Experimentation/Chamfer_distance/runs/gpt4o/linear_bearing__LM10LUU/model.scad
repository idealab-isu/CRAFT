$fn = 64;

module ball_bearing() {
    difference() {
        // Outer cylinder representing the outer diameter of the bearing
        cylinder(d = 19, h = 55, center = true);
        // Inner cylinder representing the bore
        translate([0, 0, -27.5])
            cylinder(d = 10, h = 55, center = false);
    }
}

ball_bearing();