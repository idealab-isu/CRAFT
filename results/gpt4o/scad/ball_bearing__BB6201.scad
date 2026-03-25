module ball_bearing() {
    difference() {
        // Outer cylinder
        cylinder(d=32.0, h=10.0, $fn=64);
        
        // Inner bore
        translate([0, 0, -1])
            cylinder(d=12.0, h=12.0, $fn=64);
    }
}

ball_bearing();