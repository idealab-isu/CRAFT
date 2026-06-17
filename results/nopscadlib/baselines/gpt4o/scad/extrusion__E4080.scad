module aluminium_extrusion() {
    difference() {
        cube([40, 80, 100], center = true);
        translate([-18, -38, -50])
            cube([4, 4, 100]);
        translate([14, -38, -50])
            cube([4, 4, 100]);
        translate([-18, 34, -50])
            cube([4, 4, 100]);
        translate([14, 34, -50])
            cube([4, 4, 100]);
        translate([-20, -40, -50])
            cube([40, 4, 100]);
        translate([-20, 36, -50])
            cube([40, 4, 100]);
        translate([-20, -40, -50])
            cube([4, 80, 100]);
        translate([16, -40, -50])
            cube([4, 80, 100]);
    }
}

aluminium_extrusion();