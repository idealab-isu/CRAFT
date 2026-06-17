module mains_transformer() {
    difference() {
        // Main body of the transformer
        cube([120, 88, 120], center=true);
        
        // Cutout for the core
        translate([-30, -44, -60])
            cube([60, 88, 120], center=false);
    }
}

mains_transformer();