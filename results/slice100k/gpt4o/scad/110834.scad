module flanged_bushing() {
    difference() {
        // Main body with flange
        union() {
            // Flange
            translate([0, 0, -1])
                cylinder(h=2, d=21.2, $fn=64);
            // Main cylinder
            translate([0, 0, 1])
                cylinder(h=8, d=15, $fn=64);
        }
        // Eccentric hole
        translate([3, 0, 0])
            cylinder(h=10, d=10, $fn=64);
    }
}

translate([0, 0, -5])
    flanged_bushing();