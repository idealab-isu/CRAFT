module mounting_bracket() {
    difference() {
        // Main plate
        translate([-40.6, -34.25, -5])
            cube([81.2, 68.5, 10]);

        // Central large cutout
        translate([-30, -20, -6])
            cube([60, 40, 12]);

        // Smaller rectangular window cutouts
        for (i = [-20, 0, 20])
            translate([i, -30, -6])
                cube([10, 20, 12]);

        // Circular through-hole ring feature
        translate([35, 0, -6])
            difference() {
                cylinder(h=12, r=10, $fn=64);
                translate([0, 0, -1])
                    cylinder(h=14, r=5, $fn=64);
            }

        // Fastener through-holes on tabs
        for (pos = [[-35, -30], [35, -30], [-35, 30], [35, 30]])
            translate([pos[0], pos[1], -6])
                cylinder(h=12, r=2, $fn=32);
    }
}

mounting_bracket();