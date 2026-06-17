module display_module() {
    difference() {
        // Main body of the display
        cube([84.5, 54.5, 5], center=true);
        
        // Cutout for the screen
        translate([-30, -20, -1])
            cube([60, 40, 6], center=false);
    }
}

display_module();