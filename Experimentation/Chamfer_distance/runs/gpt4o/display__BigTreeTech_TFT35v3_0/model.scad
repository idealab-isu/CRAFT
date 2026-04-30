// Define the display module with a front bezel
module display_module() {
    // Dimensions
    bezel_length = 84.5;
    bezel_width = 54.5;
    bezel_thickness = 4;
    
    // Create the front bezel
    bezel = cube([bezel_length, bezel_width, bezel_thickness], center = true);
    
    // Render the bezel
    translate([0, 0, bezel_thickness / 2])
        bezel;
}

// Call the display module to render it
display_module();