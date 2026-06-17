module shaft_support_bracket() {
    difference() {
        union() {
            // Base block
            translate([-15, -15, 0])
                cube([30, 30, 20]);
            // Cylinder for rod
            translate([0, 0, 10])
                cylinder(h = 10, d = 20, $fn = 64);
        }
        // Hole for the rod
        translate([0, 0, 10])
            cylinder(h = 20, d = 10, $fn = 64);
    }
}

shaft_support_bracket();