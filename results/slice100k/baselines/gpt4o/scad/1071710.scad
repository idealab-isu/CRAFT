module bracket() {
    difference() {
        union() {
            // Central rectangular pad
            translate([-5.5, -21.95, -1.5])
                cube([11.0, 43.9, 3.0]);

            // Left arm
            translate([-5.5, -21.95, -1.5])
                rotate([0, 10, 0])
                translate([0, -21.95, 0])
                cube([11.0, 21.95, 3.0]);

            // Right arm
            translate([-5.5, 0, -1.5])
                rotate([0, -10, 0])
                translate([0, 0, 0])
                cube([11.0, 21.95, 3.0]);
        }

        // Fillet transitions
        translate([-5.5, -21.95, -1.5])
            rotate([0, 10, 0])
            translate([0, -21.95, 0])
            cylinder(h=3.0, r1=0, r2=11.0, $fn=64);

        translate([-5.5, 0, -1.5])
            rotate([0, -10, 0])
            translate([0, 0, 0])
            cylinder(h=3.0, r1=0, r2=11.0, $fn=64);
    }
}

bracket();