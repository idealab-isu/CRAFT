// Thin hex nut: 6.0mm through hole, 10.0mm across flats, 3.2mm thick

af = 10.0;          // across flats (mm)
thickness = 3.2;    // nut thickness (mm)
hole_d = 6.0;       // through hole diameter (mm)
clearance = 0.2;    // small clearance for boolean robustness (mm)

module hex_nut(af, thickness, hole_d) {
    difference() {
        // Outer hex prism (across flats controlled by r = af/2 with $fn=6)
        cylinder(h = thickness, r = af/2, $fn = 6, center = true);

        // Central through hole (slightly longer than thickness to guarantee cut-through)
        cylinder(h = thickness + 2*clearance, d = hole_d, center = true, $fn = 64);
    }
}

hex_nut(af, thickness, hole_d);