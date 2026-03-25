module aluminium_extrusion() {
    difference() {
        cube([20, 20, 100], center = true);
        translate([-8, -8, -1])
            cube([16, 16, 102], center = true);
    }
}

aluminium_extrusion();