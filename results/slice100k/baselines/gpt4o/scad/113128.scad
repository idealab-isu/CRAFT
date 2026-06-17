module stepped_bracket() {
    difference() {
        union() {
            // Main H-like structure
            translate([-15.9, -15.9, -7.9])
                cube([31.8, 31.8, 15.8]);
            
            // Central bridge
            translate([-5, -15.9, -7.9])
                cube([10, 31.8, 15.8]);
        }
        
        // Top and bottom shoulder steps
        translate([-15.9, -15.9, 3.9])
            cube([31.8, 31.8, 3]);
        translate([-15.9, -15.9, -6.9])
            cube([31.8, 31.8, 3]);
        
        // Offset pads for asymmetric profile
        translate([-10, -10, 6.9])
            cube([20, 20, 3]);
        translate([-10, -10, -9.9])
            cube([20, 20, 3]);
    }
}

stepped_bracket();