module aluminium_extrusion() {
    difference() {
        cube([40, 40, 100], center = true);
        translate([-18, -18, -50])
            cube([4, 4, 100]);
        translate([14, -18, -50])
            cube([4, 4, 100]);
        translate([-18, 14, -50])
            cube([4, 4, 100]);
        translate([14, 14, -50])
            cube([4, 4, 100]);
        translate([-20, -20, -50])
            cube([8, 8, 100]);
        translate([12, -20, -50])
            cube([8, 8, 100]);
        translate([-20, 12, -50])
            cube([8, 8, 100]);
        translate([12, 12, -50])
            cube([8, 8, 100]);
    }
}

aluminium_extrusion();