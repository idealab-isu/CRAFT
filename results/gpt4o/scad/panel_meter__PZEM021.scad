module panel_meter() {
    difference() {
        // Main body of the panel meter
        translate([-50, -25, 0])
        cube([100, 50, 20]);

        // Display cutout
        translate([-30, -15, -1])
        cube([60, 30, 21]);

        // Button cutouts
        translate([-45, 10, -1])
        cube([10, 10, 21]);
        translate([35, 10, -1])
        cube([10, 10, 21]);

        // Screw holes
        translate([-45, -20, -1])
        cylinder(h=22, r=2, $fn=64);
        translate([45, -20, -1])
        cylinder(h=22, r=2, $fn=64);
        translate([-45, 20, -1])
        cylinder(h=22, r=2, $fn=64);
        translate([45, 20, -1])
        cylinder(h=22, r=2, $fn=64);
    }
}

panel_meter();