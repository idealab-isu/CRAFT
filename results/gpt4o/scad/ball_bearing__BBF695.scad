module flanged_ball_bearing() {
    difference() {
        // Outer cylinder of the bearing
        cylinder(h=4.0, d=13.0, $fn=64);
        
        // Inner bore
        translate([0, 0, -1])
            cylinder(h=6.0, d=5.0, $fn=64);
    }
    
    // Flange
    translate([0, 0, 4.0])
        cylinder(h=1.0, d=15.0, $fn=64);
}

flanged_ball_bearing();