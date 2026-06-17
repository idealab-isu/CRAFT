$fn = 64;

// A extrusion bracket overall: [28, 28, 20]
module corner_bracket(size=[28,28,20], wall=6, hole_d=5.2, hole_edge=7, chamfer=1.2) {
    sx = size[0];
    sy = size[1];
    sz = size[2];

    // Keep walls valid
    wall2 = min(wall, min(sx,sy)/2 - 0.5);

    difference() {
        // Main connected L-bracket body (one solid)
        // Outer block minus inner corner to form an L in plan view
        difference() {
            cube([sx, sy, sz], center=false);

            // Inner void to create L shape (opens to +X,+Y)
            translate([wall2, wall2, -0.1])
                cube([sx - wall2, sy - wall2, sz + 0.2], center=false);
        }

        // Mounting holes (2 per leg), through thickness (Z)
        // Leg along X (bottom flange): y within [0, wall2]
        for (xpos = [hole_edge, sx - hole_edge]) {
            translate([xpos, wall2/2, sz/2])
                cylinder(h=sz + 0.6, d=hole_d, center=true);
        }

        // Leg along Y (side flange): x within [0, wall2]
        for (ypos = [hole_edge, sy - hole_edge]) {
            translate([wall2/2, ypos, sz/2])
                cylinder(h=sz + 0.6, d=hole_d, center=true);
        }

        // Small outer-edge chamfers (subtractive), kept connected and non-floating
        if (chamfer > 0) {
            // Chamfer along outer top edges of both legs
            // Along X outer edge at y=sy
            translate([0, sy - chamfer, sz - chamfer])
                rotate([45, 0, 0])
                    cube([sx, chamfer*2, chamfer*2], center=false);

            // Along Y outer edge at x=sx
            translate([sx - chamfer, 0, sz - chamfer])
                rotate([0, -45, 0])
                    cube([chamfer*2, sy, chamfer*2], center=false);

            // Outer vertical corner chamfer at (sx,sy)
            translate([sx - chamfer, sy - chamfer, 0])
                rotate([0, 0, 45])
                    cube([chamfer*2, chamfer*2, sz], center=false);
        }
    }
}

corner_bracket();