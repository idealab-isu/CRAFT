module aluminium_extrusion() {
    difference() {
        cube([20, 60, 100], center = true);
        translate([-8, -28, -50])
            cube([16, 56, 100], center = false);
    }
}

aluminium_extrusion();