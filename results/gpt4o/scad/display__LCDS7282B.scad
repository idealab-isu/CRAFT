module display_module() {
    difference() {
        // Main body of the display
        cube([73.6, 28.7, 5], center=true);
        
        // Cutout for the screen area
        translate([-30, -10, -1])
            cube([60, 20, 6], center=false);
    }
}

display_module();