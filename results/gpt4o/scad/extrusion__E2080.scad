module aluminium_extrusion() {
    difference() {
        cube([20, 80, 100], center = true);
        translate([-8, -38, -50])
            cube([4, 76, 100]);
        translate([4, -38, -50])
            cube([4, 76, 100]);
        translate([-8, -38, -50])
            cube([16, 4, 100]);
        translate([-8, 34, -50])
            cube([16, 4, 100]);
    }
}

aluminium_extrusion();