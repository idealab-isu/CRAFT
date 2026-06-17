module bracket() {
    difference() {
        union() {
            // V-shaped flared plate
            translate([-26.15, -25, 0])
            hull() {
                translate([0, 0, 0])
                cube([5, 50, 5]);
                translate([47.3, 0, 0])
                cube([5, 50, 5]);
            }
            
            // Central ridge/crease
            translate([-1.5, -25, 5])
            cube([3, 50, 5]);
            
            // Rectangular stem
            translate([-5, -5, 0])
            cube([10, 10, 38.8]);
        }
        
        // Circular through-hole
        translate([0, 0, 19.4])
        rotate([90, 0, 0])
        cylinder(h=10, r=2.5, $fn=64);
    }
}

bracket();