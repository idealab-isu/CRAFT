module ball_bearing() {
    difference() {
        // Outer ring
        cylinder(h=7.0, d=52.0, $fn=64);
        
        // Inner bore
        translate([0, 0, -1])
            cylinder(h=9.0, d=40.0, $fn=64);
    }
}

ball_bearing();