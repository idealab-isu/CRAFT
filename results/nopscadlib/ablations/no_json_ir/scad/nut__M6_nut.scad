// Hex nut: 6.0mm screw, 11.5mm across flats, 5.0mm thick

af = 11.5;          // across flats (mm)
thk = 5.0;          // thickness (mm)
hole_d = 6.0;       // through-hole diameter (mm) for 6.0mm screw
chamfer = 0.6;      // edge chamfer height (mm)
eps = 0.02;

function r_from_af(af) = af / (2 * cos(30));  // circumradius for $fn=6

module hex_nut() {
    R = r_from_af(af);

    difference() {
        // One connected solid: hex body with top/bottom chamfers
        union() {
            // Middle straight section
            translate([0, 0, chamfer])
                cylinder(h = thk - 2*chamfer, r = R, $fn = 6);

            // Top chamfer (tapers inward)
            translate([0, 0, thk - chamfer])
                cylinder(h = chamfer, r1 = R, r2 = R - chamfer, $fn = 6);

            // Bottom chamfer (tapers inward)
            cylinder(h = chamfer, r1 = R - chamfer, r2 = R, $fn = 6);
        }

        // Central through-hole (fully cuts through with margin)
        translate([0, 0, -eps])
            cylinder(h = thk + 2*eps, d = hole_d, $fn = 64);
    }
}

hex_nut();