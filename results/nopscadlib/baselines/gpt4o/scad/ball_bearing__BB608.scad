module ball_bearing() {
    difference() {
        // Outer cylinder
        cylinder(h=7.0, d=22.0, $fn=64);
        
        // Inner bore
        translate([0, 0, -1])
            cylinder(h=9.0, d=8.0, $fn=64);
    }
}

ball_bearing();