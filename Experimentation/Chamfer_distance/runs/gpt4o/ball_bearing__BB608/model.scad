$fn = 64;

module ball_bearing() {
    difference() {
        // Outer cylinder
        cylinder(d = 22, h = 7, center = true);
        // Inner bore
        cylinder(d = 8, h = 7, center = true);
    }
}

translate([0, 0, 0])
    ball_bearing();