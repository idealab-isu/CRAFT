module flanged_ball_bearing() {
    difference() {
        // Outer cylinder of the bearing
        cylinder(h=5.0, d=16.0, $fn=64);
        
        // Inner bore
        translate([0, 0, -1])
            cylinder(h=7.0, d=5.0, $fn=64);
    }
    
    // Flange
    translate([0, 0, 5.0])
        cylinder(h=1.0, d=18.0, $fn=64);
}

flanged_ball_bearing();