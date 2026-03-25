module ball_bearing() {
    difference() {
        // Outer cylinder
        cylinder(d=30.0, h=9.0, $fn=64);
        
        // Inner bore
        translate([0, 0, -1])
            cylinder(d=10.0, h=11.0, $fn=64);
    }
}

ball_bearing();