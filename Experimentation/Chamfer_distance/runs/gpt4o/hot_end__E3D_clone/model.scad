$fn = 64;

module hot_end_assembly() {
    difference() {
        // Overall cylinder for the hot-end assembly
        cylinder(h = 66, d = 16, center = true);

        // Create the mounting groove
        translate([0, 0, -33 + 6.8])
            cylinder(h = 5.6, d = 12, center = false);
    }
}

// Center the model near the origin
translate([0, 0, -33])
    hot_end_assembly();