module c_shaped_bracket() {
    difference() {
        // Main block
        cube([31.8, 31.8, 15.8], center = true);
        
        // Internal cutout
        translate([-15.9, -10, -7.9])
            cube([31.8, 20, 10], center = false);
    }
    
    // Protruding lug/stop
    translate([10, 15.9, -7.9])
        cube([5, 5, 15.8], center = false);
}

c_shaped_bracket();