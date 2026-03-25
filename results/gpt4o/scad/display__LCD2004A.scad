module display_module() {
    difference() {
        // Main body of the display
        cube([97, 39.5, 10], center=true);
        
        // Cutout for the display screen
        translate([-40, -10, -1])
            cube([80, 20, 12], center=false);
    }
}

display_module();