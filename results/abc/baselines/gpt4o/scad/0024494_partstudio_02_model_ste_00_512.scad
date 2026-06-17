module u_shaped_clamp() {
    difference() {
        union() {
            // Main body with chamfered edges
            hull() {
                translate([-25, -10, 0])
                    cube([50, 20, 10]);
                translate([-25, 10, 0])
                    cube([50, 20, 10]);
            }
            // Prongs
            translate([-25, -5, 0])
                cube([50, 5, 10]);
            translate([-25, 5, 0])
                cube([50, 5, 10]);
        }
        // Semicircular cutout
        translate([0, 0, -5])
            rotate([90, 0, 0])
                cylinder(r=10, h=20, $fn=64);
        // Through-holes
        translate([-20, 0, 5])
            rotate([45, 0, 0])
                cylinder(r=2, h=20, $fn=64);
        translate([20, 0, 5])
            rotate([45, 0, 0])
                cylinder(r=2, h=20, $fn=64);
    }
}

u_shaped_clamp();