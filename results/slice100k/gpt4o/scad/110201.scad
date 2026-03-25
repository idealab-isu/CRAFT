module u_shaped_mounting_strap() {
    difference() {
        union() {
            // Semicircular arched center section
            translate([0, 0, 8])
                rotate([90, 0, 0])
                cylinder(h=48, r=5, $fn=64);

            // Left end tab
            translate([-24, 0, -8])
                cube([8, 10, 16], center=true);

            // Right end tab
            translate([24, 0, -8])
                cube([8, 10, 16], center=true);
        }

        // Left hole
        translate([-24, 0, 0])
            cylinder(h=16, r=2, $fn=64);

        // Right hole
        translate([24, 0, 0])
            cylinder(h=16, r=2, $fn=64);
    }
}

u_shaped_mounting_strap();