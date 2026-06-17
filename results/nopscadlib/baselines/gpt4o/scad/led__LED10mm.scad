module led() {
    difference() {
        union() {
            // LED body
            cylinder(h = 11.0, d = 10.0, $fn = 64);
            // LED dome
            translate([0, 0, 11.0])
                sphere(d = 10.0, $fn = 64);
        }
        // Through-hole
        translate([0, 0, -1])
            cylinder(h = 13.0, d = 2.0, $fn = 64);
    }
}

led();