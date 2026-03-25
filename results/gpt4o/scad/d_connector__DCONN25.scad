module d_connector() {
    difference() {
        union() {
            // Main body
            translate([-30, -10, 0])
            cube([60, 20, 5]);

            // Rounded ends
            translate([-35, 0, 0])
            rotate([90, 0, 0])
            cylinder(h=20, r=5, $fn=64);

            translate([35, 0, 0])
            rotate([90, 0, 0])
            cylinder(h=20, r=5, $fn=64);
        }

        // Cut out the top to create the D shape
        translate([-30, -10, 0])
        cube([60, 20, 5]);

        translate([-30, -10, 0])
        rotate([90, 0, 0])
        cylinder(h=20, r=10, $fn=64);
    }
}

d_connector();