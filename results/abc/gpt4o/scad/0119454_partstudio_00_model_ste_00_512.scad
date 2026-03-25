module u_shaped_bracket() {
    difference() {
        // Main prismatic body
        union() {
            // Base rectangular prism
            translate([-0.05, -0.05, -0.05])
                cube([0.1, 0.1, 0.1]);
            // Chamfered end
            translate([-0.05, -0.05, -0.05])
                rotate([0, 45, 0])
                cube([0.1, 0.1, 0.1]);
            // Rounded end
            translate([0.05, 0, 0])
                rotate([0, 90, 0])
                cylinder(h=0.1, r=0.05, $fn=64);
        }
        // Rectangular through-slot
        translate([-0.05, -0.02, -0.05])
            cube([0.1, 0.04, 0.1]);
        // Hexagonal through-hole
        translate([0.04, 0, 0])
            rotate([90, 0, 0])
            cylinder(h=0.1, r=0.02, $fn=6);
    }
}

u_shaped_bracket();