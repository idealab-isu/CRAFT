module iec_inlet() {
    difference() {
        // Main body
        union() {
            // Main rectangular body
            translate([-20, -14.5, 0])
                cube([40, 29, 20]);
            // Cylindrical filter part
            translate([0, 0, 10])
                cylinder(h=10, r=10, $fn=64);
        }
        // Cutout for the inlet
        translate([-15, -9.5, 0])
            cube([30, 19, 20]);
    }
}

iec_inlet();