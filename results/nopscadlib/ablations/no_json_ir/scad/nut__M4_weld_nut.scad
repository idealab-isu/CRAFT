$fn = 64;

across_flats = 5.3;     // mm
thickness    = 6.3;     // mm
screw_diam   = 4.0;     // mm

// Circumradius for a regular hex given across-flats:
// across_flats = 2 * R * cos(30°)  =>  R = across_flats / (2*cos(30°))
hex_R = across_flats / (2 * cos(30));

module hex_nut() {
    difference() {
        // Outer hex body
        cylinder(h = thickness, r = hex_R, $fn = 6);

        // Central through-hole (slightly extended to guarantee cut-through)
        translate([0, 0, -0.5])
            cylinder(h = thickness + 1.0, r = screw_diam / 2, $fn = 64);
    }
}

hex_nut();