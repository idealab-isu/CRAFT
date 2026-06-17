module l_shaped_bracket() {
    difference() {
        // Main block
        cube([0.1, 0.2, 0.01], center = true);
        // Cutout for the L-shape
        translate([-0.05, -0.1, -0.005])
            cube([0.05, 0.1, 0.01], center = false);
    }
}

l_shaped_bracket();