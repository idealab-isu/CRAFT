module chamfered_plate() {
    difference() {
        // Main block with chamfered edges
        hull() {
            for (x = [-1.55, 1.55])
                for (y = [-0.8, 0.8])
                    translate([x, y, 0])
                        cylinder(h = 0.5, r = 0.1, $fn = 64);
        }
        // Recessed panel with raised border
        translate([0, 0, 0.1])
            offset(r = 0.1)
                offset(delta = -0.1)
                    hull() {
                        for (x = [-1.45, 1.45])
                            for (y = [-0.7, 0.7])
                                translate([x, y, 0])
                                    cylinder(h = 0.3, r = 0.1, $fn = 64);
                    }
    }
}

chamfered_plate();