module iec_lugless() {
    difference() {
        union() {
            // Main body
            cylinder(h=20, r=10, $fn=64);
            // Top dome
            translate([0, 0, 20])
                sphere(r=10, $fn=64);
        }
        // Bottom cut
        translate([0, 0, -5])
            cylinder(h=5, r=8, $fn=64);
    }
}

iec_lugless();