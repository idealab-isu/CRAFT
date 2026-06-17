module prismatic_bar() {
    difference() {
        // Main bar
        translate([-52.55, -4.85, -6])
            cube([105.1, 9.7, 12]);

        // Circular through-holes
        for (i = [-40, -20, 0, 20, 40]) {
            translate([i, 0, 0])
                cylinder(h = 12, r = 2, $fn = 64);
        }

        // U-shaped forked slot
        translate([47.55, -2.85, -6])
            cube([10, 5.7, 12]);
    }
}

prismatic_bar();