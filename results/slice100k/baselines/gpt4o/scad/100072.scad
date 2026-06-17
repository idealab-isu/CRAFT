module rounded_prism() {
    difference() {
        // Main block with rounded edges
        hull() {
            translate([-18, -9.5, -10.5]) cube([36, 1, 21]);
            translate([-18, 8.5, -10.5]) cube([36, 1, 21]);
            translate([-18, -9.5, -10.5]) cube([1, 19, 21]);
            translate([17, -9.5, -10.5]) cube([1, 19, 21]);
        }
        // Side cutouts
        translate([-18, -9.5, -10.5]) cube([36, 6, 21]);
        translate([-18, 3.5, -10.5]) cube([36, 6, 21]);
    }
}

rounded_prism();