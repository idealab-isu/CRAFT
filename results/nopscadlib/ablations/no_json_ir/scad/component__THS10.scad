$fn = 64;

// Rectangular base with component-like features (holes + top boss), all connected
module component() {
    // Dimensions chosen to match views: square front/back/left/right, rectangular top/bottom
    base_xy = 30;
    base_h  = 10;

    boss_r = 6;
    boss_h = 4;

    hole_r = 2.2;
    hole_inset = 6; // from each edge

    difference() {
        union() {
            // Main body
            cube([base_xy, base_xy, base_h], center=true);

            // Top boss (connected with slight overlap)
            translate([0, 0, base_h/2 + boss_h/2 - 0.5])
                cylinder(r=boss_r, h=boss_h, center=true);
        }

        // 4 through mounting holes (component-specific detail)
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*(base_xy/2 - hole_inset), sy*(base_xy/2 - hole_inset), 0])
                cylinder(r=hole_r, h=base_h + boss_h + 2, center=true);
        }

        // Shallow top recess around boss to add more identifiable geometry
        recess_r = boss_r + 3;
        recess_h = 1.5;
        translate([0, 0, base_h/2 - recess_h/2 + 0.01])
            cylinder(r=recess_r, h=recess_h, center=true);
    }
}

component();