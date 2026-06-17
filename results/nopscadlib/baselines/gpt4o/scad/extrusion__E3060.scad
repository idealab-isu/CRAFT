module aluminium_extrusion() {
    difference() {
        cube([30, 60, 100], center = true);
        translate([-12.5, -27.5, -50])
            cube([25, 55, 100], center = false);
    }
}

aluminium_extrusion();