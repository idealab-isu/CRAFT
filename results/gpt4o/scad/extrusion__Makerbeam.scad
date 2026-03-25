module aluminium_extrusion() {
    difference() {
        cube([10, 10, 100], center = true);
        translate([-4.5, -4.5, -50])
            cube([9, 9, 100]);
    }
}

aluminium_extrusion();