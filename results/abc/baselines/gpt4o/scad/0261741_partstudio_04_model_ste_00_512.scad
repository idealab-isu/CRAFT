module tabbed_plate() {
    difference() {
        // Main plate
        cube([30, 30, 1], center=true);
        
        // Top tab
        translate([0, 15, 0])
            cube([10, 5, 1], center=true);
        
        // Bottom tab
        translate([0, -15, 0])
            cube([10, 5, 1], center=true);
        
        // Left tab
        translate([-15, 0, 0])
            cube([5, 10, 1], center=true);
        
        // Right tab
        translate([15, 0, 0])
            cube([5, 10, 1], center=true);
    }
}

tabbed_plate();