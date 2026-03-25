module flanged_ball_bearing() {
    difference() {
        // Outer cylinder
        cylinder(d=10.0, h=4.0, $fn=64);
        
        // Inner bore
        translate([0, 0, -1])
            cylinder(d=3.0, h=6.0, $fn=64);
    }
    
    // Flange
    translate([0, 0, 4.0])
        cylinder(d=11.5, h=1.0, $fn=64);
}

flanged_ball_bearing();