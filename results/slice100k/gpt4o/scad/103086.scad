module c_bracket() {
    difference() {
        union() {
            // Main U-shape
            translate([-27.7, -15.75, 0])
            cube([55.4, 31.5, 5]);

            // Taller leg
            translate([-27.7, -15.75, 5])
            cube([5, 31.5, 32.5]);

            // Shorter leg
            translate([22.7, -15.75, 5])
            cube([5, 31.5, 20]);

            // Chamfer on taller leg
            translate([-27.7, -15.75, 37.5])
            rotate([0, 45, 0])
            cube([5, 31.5, 5]);
        }

        // Hexagonal hole
        translate([0, 0, 2.5])
        rotate([0, 0, 90])
        cylinder(h=5, r=3, $fn=6);
    }
}

c_bracket();