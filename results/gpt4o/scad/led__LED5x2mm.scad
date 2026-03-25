module led() {
    difference() {
        union() {
            // LED dome
            translate([0, 0, 5])
                sphere(r=5, $fn=64);
            // LED cylinder
            translate([0, 0, -5])
                cylinder(h=10, r=5, $fn=64);
        }
        // Flattened bottom
        translate([-10, -10, -5])
            cube([20, 20, 5]);
    }
    // LED leads
    translate([-1.5, 0, -15])
        cylinder(h=10, r=0.75, $fn=32);
    translate([1.5, 0, -15])
        cylinder(h=10, r=0.75, $fn=32);
}

led();