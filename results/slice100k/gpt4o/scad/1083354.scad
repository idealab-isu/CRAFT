module hollow_tube() {
    $fn = 64;
    difference() {
        union() {
            // Bottom cylinder
            translate([0, 0, -48.75])
                cylinder(h = 48.75, r1 = 9.5, r2 = 9.5);
            // Frustum (conical transition)
            translate([0, 0, 0])
                cylinder(h = 10, r1 = 9.5, r2 = 6.5);
            // Top cylinder
            translate([0, 0, 10])
                cylinder(h = 38.75, r1 = 6.5, r2 = 6.5);
        }
        // Central through-bore
        translate([0, 0, -48.75])
            cylinder(h = 97.5, r = 3.5);
    }
}

hollow_tube();