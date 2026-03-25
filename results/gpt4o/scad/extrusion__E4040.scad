module aluminium_extrusion() {
    difference() {
        cube([40, 40, 100], center = true);
        translate([-18, -18, -1])
            cube([36, 36, 102], center = true);
        for (x = [-15, 15]) {
            for (y = [-15, 15]) {
                translate([x, y, 0])
                    cylinder(h = 100, r = 3, center = true, $fn = 64);
            }
        }
    }
}

aluminium_extrusion();