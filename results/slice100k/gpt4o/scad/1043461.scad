module bracket() {
    difference() {
        union() {
            // Central block with square window
            translate([-5.45, -21.95, -5.3])
                cube([10.9, 10.9, 10.6]);
            translate([-2.5, -2.5, -5.3])
                cube([5, 5, 10.6]);

            // Left arm
            translate([-5.45, -43.9, -5.3])
                cube([10.9, 16.95, 10.6]);

            // Right arm
            translate([-5.45, 11.05, -5.3])
                cube([10.9, 16.95, 10.6]);

            // Ribs on one face
            for (i = [-4, -2, 0, 2, 4]) {
                translate([i, -21.95, 5.3])
                    cube([1, 43.9, 1]);
            }
        }
        // Fillet transitions (approximated with small cubes)
        translate([-5.45, -11.05, -5.3])
            cube([10.9, 1, 10.6]);
        translate([-5.45, 10.05, -5.3])
            cube([10.9, 1, 10.6]);
    }
}

bracket();