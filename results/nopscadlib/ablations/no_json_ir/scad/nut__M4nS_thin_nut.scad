// Thin hex nut: 4.0mm screw clearance, 7.0mm across flats, 2.2mm thick

af = 7.0;          // across flats (mm)
thk = 2.2;         // thickness (mm)
hole_d = 4.0;      // through-hole diameter (mm)
clearance = 0.2;   // small extra clearance (mm)

$fn = 96;

module hex_nut(af, thk, hole_d) {
    // For a 6-sided cylinder, OpenSCAD's r is circumradius.
    // Across flats = 2 * r * cos(30)  =>  r = af / (2*cos(30))
    r_hex = af / (2 * cos(30));

    difference() {
        // Centered body for robust boolean ops and easy verification
        cylinder(h = thk, r = r_hex, $fn = 6, center = true);

        // Through-hole, extended beyond thickness to guarantee a clean cut
        cylinder(h = thk + 2, r = (hole_d + clearance) / 2, $fn = 96, center = true);
    }
}

hex_nut(af, thk, hole_d);