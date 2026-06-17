module aluminium_extrusion() {
    difference() {
        cube([20, 40, 100], center = true);
        translate([-8, -18, -50])
            cube([16, 36, 100], center = false);
    }
}

aluminium_extrusion();