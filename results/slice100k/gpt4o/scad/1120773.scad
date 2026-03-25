module x_shaped_bracket() {
    difference() {
        union() {
            // Central rectangular plate
            translate([-46.35, -33.85, 0])
                cube([92.7, 67.7, 2]);

            // Diagonal arms
            for (angle = [45, 135, 225, 315]) {
                rotate([0, 0, angle])
                    translate([0, 0, 1])
                        cube([92.7, 10, 2], center = true);
            }

            // Circular lugs/bosses
            for (angle = [45, 135, 225, 315]) {
                rotate([0, 0, angle])
                    translate([46.35, 0, 0])
                        cylinder(h = 4, d = 10, $fn = 64);
            }
        }

        // Through-holes in the lugs
        for (angle = [45, 135, 225, 315]) {
            rotate([0, 0, angle])
                translate([46.35, 0, 2])
                    cylinder(h = 10, d = 5, $fn = 64);
        }
    }
}

x_shaped_bracket();