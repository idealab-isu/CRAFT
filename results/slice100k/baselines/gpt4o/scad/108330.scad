module hexagonal_prism_with_hole_and_grooves() {
    difference() {
        // Hexagonal prism
        translate([0, 0, -3.5])
            rotate([0, 0, 30])
                cylinder(h=7, r=23.1, $fn=6);

        // Circular through-hole
        translate([0, 0, -10])
            cylinder(h=20, r=5, $fn=64);

        // V-shaped grooves
        for (angle = [0, 180]) {
            rotate([0, 0, angle])
                translate([0, 20, -3.5])
                    rotate([90, 0, 0])
                        chevron_groove();
        }
    }
}

module chevron_groove() {
    difference() {
        // Base groove shape
        translate([-23.1, -1.5, 0])
            cube([46.2, 3, 7]);

        // V-shape cut
        translate([-23.1, -1.5, 0])
            intersection() {
                cube([46.2, 3, 7]);
                rotate([0, 0, 45])
                    translate([-23.1, -23.1, 0])
                        cube([46.2, 46.2, 7]);
                rotate([0, 0, -45])
                    translate([-23.1, -23.1, 0])
                        cube([46.2, 46.2, 7]);
            }
    }
}

hexagonal_prism_with_hole_and_grooves();