module l_bracket() {
    difference() {
        union() {
            // Base plate
            translate([-0.05, -0.05, 0])
            cube([0.1, 0.1, 0.02]);

            // Upright plate
            translate([-0.05, 0, 0.02])
            cube([0.1, 0.02, 0.08]);

            // Internal fillet
            translate([-0.05, 0, 0.02])
            rotate([90, 0, 0])
            cylinder(r=0.02, h=0.02, $fn=64);
        }

        // Beveled region near the bend
        translate([-0.05, 0.02, 0.02])
        rotate([45, 0, 0])
        cube([0.1, 0.02, 0.02]);

        // Through-hole in the upright leg
        translate([0, 0.01, 0.06])
        cylinder(r=0.005, h=0.02, $fn=64);
    }
    
    // Thickened flange/lip along one edge
    translate([-0.05, -0.05, 0])
    cube([0.1, 0.01, 0.02]);
}

l_bracket();