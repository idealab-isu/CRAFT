module bracket() {
    difference() {
        union() {
            // Base plate
            translate([-26.15, -25, 0])
                cube([52.3, 50, 2]);

            // Side walls
            translate([-26.15, -25, 2])
                rotate([0, 0, 45])
                cube([52.3, 2, 36.8]);
            translate([-26.15, 23, 2])
                rotate([0, 0, -45])
                cube([52.3, 2, 36.8]);

            // Mounting tab
            translate([-10, -5, 0])
                cube([20, 10, 2]);
        }

        // Hole in the mounting tab
        translate([0, 0, -1])
            cylinder(h=4, d=5, $fn=64);
    }
}

bracket();