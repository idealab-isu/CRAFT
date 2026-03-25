module led() {
    difference() {
        union() {
            // LED body
            cylinder(h=3.15, d=3.0, $fn=64);
            // LED dome
            translate([0, 0, 3.15])
                sphere(d=3.0, $fn=64);
        }
        // Through-hole
        translate([0, 0, -1])
            cylinder(h=5, d=1.0, $fn=64);
    }
}

led();