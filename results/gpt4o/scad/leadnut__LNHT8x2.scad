module leadscrew_nut_housing() {
    difference() {
        // Main block
        cube([30, 34, 30], center=true);
        
        // Leadscrew hole
        translate([0, 0, 0])
            cylinder(h=30, r=5, center=true, $fn=64);
    }
}

leadscrew_nut_housing();