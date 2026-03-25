module key() {
    difference() {
        union() {
            // Shank
            translate([-0.1, -0.05, 0])
            cube([0.1, 0.02, 0]);

            // Bow (ring)
            translate([-0.1, 0.03, 0])
            difference() {
                cylinder(r=0.03, h=0, $fn=64);
                translate([0, 0, -0.01])
                cylinder(r=0.015, h=0.02, $fn=64);
            }

            // Bit with stepped notches and triangular tooth
            translate([-0.1, -0.05, 0])
            union() {
                // Rectangular notches
                translate([0.08, 0, 0])
                cube([0.02, 0.01, 0]);
                translate([0.06, 0.01, 0])
                cube([0.02, 0.01, 0]);

                // Triangular tooth
                translate([0.04, 0.02, 0])
                polygon(points=[[0, 0], [0.02, 0], [0.01, 0.01]]);
            }
        }
    }
}

key();