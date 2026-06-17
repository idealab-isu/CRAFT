// Hex nut: 4.0mm screw, 8.1mm across flats, 3.2mm thick

af = 8.1;          // across flats (mm)
th = 3.2;          // thickness (mm)
hole_d = 4.0;      // through-hole diameter (mm) for M4 screw (simple clearance)
chamfer = 0.4;     // edge chamfer height (mm)
eps = 0.02;

$fn = 96;

module hex_prism(h, af_dim) {
    // For a 6-sided cylinder, across-flats = 2 * r * cos(30) = r * sqrt(3)
    r = af_dim / sqrt(3);
    cylinder(h=h, r=r, $fn=6, center=true);
}

module hex_nut() {
    difference() {
        // Outer body with top/bottom chamfers, all connected as one solid
        union() {
            // Middle straight section
            hex_prism(th - 2*chamfer, af);

            // Top chamfer (slightly smaller AF at the very top)
            translate([0, 0, (th - chamfer)/2])
                cylinder(h=chamfer, r1=(af/sqrt(3)), r2=((af - 0.5)/sqrt(3)), $fn=6, center=true);

            // Bottom chamfer
            translate([0, 0, -(th - chamfer)/2])
                cylinder(h=chamfer, r1=((af - 0.5)/sqrt(3)), r2=(af/sqrt(3)), $fn=6, center=true);
        }

        // Through-hole
        cylinder(h=th + 2*eps, d=hole_d, center=true, $fn=96);
    }
}

hex_nut();