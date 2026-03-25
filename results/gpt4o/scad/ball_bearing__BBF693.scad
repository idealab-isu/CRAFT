module flanged_ball_bearing() {
    difference() {
        // Outer cylinder of the bearing
        cylinder(h=3.0, d=8.0, $fn=64);
        
        // Inner bore
        translate([0, 0, -1])
            cylinder(h=5.0, d=3.0, $fn=64);
    }
    
    // Flange
    translate([0, 0, 3.0])
        cylinder(h=0.5, d=9.5, $fn=64);
}

flanged_ball_bearing();