// Define the D-subminiature connector
module d_sub_connector() {
    // Flange dimensions
    flange_width = 39.14;
    flange_height = 12.55;
    flange_thickness = 1.12;
    
    // Mounting hole pitch
    hole_pitch = 33.32;
    hole_radius = 1.5; // Approximate size for mounting holes
    
    // Create the flange
    difference() {
        cube([flange_width, flange_height, flange_thickness], center = true);
        
        // Create mounting holes
        translate([-hole_pitch / 2, 0, 0])
            cylinder(h = flange_thickness + 1, r = hole_radius, center = true, $fn = 64);
        translate([hole_pitch / 2, 0, 0])
            cylinder(h = flange_thickness + 1, r = hole_radius, center = true, $fn = 64);
    }
}

// Call the module to render the connector
d_sub_connector();