module shaft_support_bracket() {
    difference() {
        union() {
            // Base block
            translate([-10, -10, 0])
                cube([20, 20, 20]);
            // Rod hole
            translate([0, 0, 10])
                cylinder(h=20, r=4, $fn=64);
        }
        // Cutout for the rod
        translate([0, 0, 0])
            cylinder(h=20, r=4, $fn=64);
    }
}

shaft_support_bracket();