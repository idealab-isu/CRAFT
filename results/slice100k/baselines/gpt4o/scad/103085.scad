module bracket() {
    difference() {
        union() {
            // Horizontal beam
            translate([-27.7, -15.75, -5])
                cube([55.4, 10, 10]);

            // Tall vertical end plate with chamfer
            translate([-27.7, -15.75, 5])
                difference() {
                    cube([10, 10, 32.5]);
                    translate([0, 0, 22.5])
                        rotate([0, 45, 0])
                        cube([10, 10, 10]);
                }

            // Short vertical support/leg
            translate([17.7, -15.75, -5])
                cube([10, 10, 20]);
        }

        // Hexagonal hole in the horizontal beam
        translate([0, 0, 0])
            rotate([90, 0, 0])
            cylinder(h=10, r=5, $fn=6);
    }
}

bracket();