$fn = 96;

// Generic parametric component: base plate with four mounting holes,
// central boss, and a through bore.
module component(
    base_x = 80,
    base_y = 50,
    base_z = 6,
    corner_r = 6,

    hole_d = 4.2,
    hole_edge_offset = 8,

    boss_d = 26,
    boss_h = 14,

    bore_d = 10,

    chamfer = 0.8
) {
    difference() {
        union() {
            // Base with rounded corners
            linear_extrude(height = base_z)
                offset(r = corner_r)
                    square([base_x - 2*corner_r, base_y - 2*corner_r], center = true);

            // Central boss
            translate([0, 0, base_z])
                cylinder(d = boss_d, h = boss_h);
        }

        // Through bore (through boss + base)
        translate([0, 0, -0.5])
            cylinder(d = bore_d, h = base_z + boss_h + 1);

        // Mounting holes (4)
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([
                sx * (base_x/2 - hole_edge_offset),
                sy * (base_y/2 - hole_edge_offset),
                -0.5
            ])
                cylinder(d = hole_d, h = base_z + 1);
        }

        // Light top chamfer on boss (simple conical cut)
        if (chamfer > 0) {
            translate([0, 0, base_z + boss_h - chamfer])
                cylinder(d1 = boss_d + 2*chamfer, d2 = boss_d - 2*chamfer, h = chamfer + 0.01);
        }
    }
}

component();