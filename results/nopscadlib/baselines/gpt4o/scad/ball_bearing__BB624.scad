module ball_bearing() {
    difference() {
        // Outer cylinder
        cylinder(d=13.0, h=5.0, $fn=64);
        
        // Inner bore
        translate([0, 0, -1])
            cylinder(d=4.0, h=7.0, $fn=64);
    }
}

ball_bearing();