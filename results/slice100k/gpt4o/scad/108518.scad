module ring_with_notches() {
    difference() {
        // Outer ring
        cylinder(h=11.8, r=30, $fn=64);
        
        // Central through-bore
        translate([0, 0, -1])
            cylinder(h=13.8, r=20, $fn=64);
        
        // Rectangular notches
        for (i = [0:5]) {
            rotate([0, 0, i * 60])
                translate([20, -2, -1])
                    cube([4, 4, 13.8]);
        }
    }
}

ring_with_notches();