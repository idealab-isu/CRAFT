module component() {
    difference() {
        union() {
            // Base cylinder
            cylinder(h=20, r=10, $fn=64);
            // Top sphere
            translate([0, 0, 20])
                sphere(r=10, $fn=64);
        }
        // Hole through the center
        translate([0, 0, -5])
            cylinder(h=30, r=3, $fn=64);
    }
}

component();