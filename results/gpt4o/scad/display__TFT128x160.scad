module display_module() {
    // Main display body
    difference() {
        // Outer frame
        cube([46, 34, 5], center=true);
        // Inner screen cutout
        translate([-21, -15, -1])
            cube([42, 30, 6], center=false);
    }
}

display_module();