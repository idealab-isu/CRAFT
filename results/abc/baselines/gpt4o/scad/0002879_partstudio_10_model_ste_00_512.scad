module arc_bracket() {
    difference() {
        union() {
            // Outer arc
            rotate([0, 90, 0])
            translate([0, 0, -0.2])
            cylinder(r=0.2, h=0.3, $fn=64);

            // Inner arc
            rotate([0, 90, 0])
            translate([0, 0, -0.2])
            cylinder(r=0.15, h=0.3, $fn=64);

            // End block with tab
            translate([-0.15, -0.05, 0.1])
            cube([0.1, 0.1, 0.1]);

            // Protruding tab
            translate([-0.15, -0.025, 0.2])
            cube([0.05, 0.05, 0.05]);
        }

        // Tapered slot
        translate([-0.15, -0.05, 0])
        rotate([0, 90, 0])
        cylinder(r1=0.05, r2=0.02, h=0.3, $fn=64);
    }
}

translate([0, 0, -0.2])
arc_bracket();