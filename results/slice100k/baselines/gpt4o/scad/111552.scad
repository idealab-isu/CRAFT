module rounded_link() {
    difference() {
        union() {
            // Main body with rounded ends
            translate([-51, -3.5, -1.75])
                cube([102, 7, 3.5]);
            translate([-51, 0, -1.75])
                cylinder(h=3.5, r=3.5, $fn=64);
            translate([51, 0, -1.75])
                cylinder(h=3.5, r=3.5, $fn=64);
        }
        // Holes near each end
        translate([-40, 0, -5])
            cylinder(h=10, r=1.75, $fn=64);
        translate([40, 0, -5])
            cylinder(h=10, r=1.75, $fn=64);
    }
}

rounded_link();