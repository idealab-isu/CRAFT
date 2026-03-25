module hex_plate_with_hole() {
    difference() {
        // Hexagonal plate
        union() {
            // Main hexagonal body
            translate([0, 0, -2])
                cylinder(h=4, r=12.5, $fn=6);
            // Boss/recess feature
            translate([0, 0, -1])
                cylinder(h=2, r=10, $fn=6);
        }
        // Central circular through-hole
        translate([0, 0, -2])
            cylinder(h=8, r=5, $fn=64);
    }
}

hex_plate_with_hole();