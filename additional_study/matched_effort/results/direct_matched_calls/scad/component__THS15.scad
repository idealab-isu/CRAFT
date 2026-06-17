$fn = 96;

module component() {
    // Basic parametric "component" placeholder: a rounded rectangular base
    // with a central boss and two mounting holes.
    base_l = 60;
    base_w = 30;
    base_h = 6;
    corner_r = 4;

    boss_d = 18;
    boss_h = 10;

    hole_d = 4.2;
    hole_spacing = 40;

    difference() {
        union() {
            // Rounded base
            linear_extrude(height = base_h)
                offset(r = corner_r)
                    square([base_l - 2*corner_r, base_w - 2*corner_r], center = true);

            // Central boss
            translate([0, 0, base_h])
                cylinder(d = boss_d, h = boss_h);
        }

        // Mounting holes through base
        for (x = [-hole_spacing/2, hole_spacing/2]) {
            translate([x, 0, -1])
                cylinder(d = hole_d, h = base_h + boss_h + 2);
        }

        // Central clearance hole through boss
        translate([0, 0, -1])
            cylinder(d = 8, h = base_h + boss_h + 2);
    }
}

component();