$fn = 96;

// Target dimensions
af = 9.2;          // across flats (mm)
thickness = 4.0;   // nut thickness (mm)
hole_d = 5.0;      // through-hole diameter (mm)

// Derived
R = af / sqrt(3);  // circumradius for a true hex with given across-flats
chamfer_h = 0.6;   // small edge chamfer height (mm)
chamfer_inset = 0.5; // radial inset for chamfer (mm)

module hex_prism(h, r) {
    cylinder(h=h, r=r, $fn=6, center=true);
}

module hex_nut() {
    difference() {
        // One connected solid: union of main body + chamfered rims
        union() {
            // Main hex body
            hex_prism(thickness, R);

            // Top chamfer ring (overlaps into body)
            translate([0, 0, thickness/2 - chamfer_h/2])
                hex_prism(chamfer_h, R);

            // Bottom chamfer ring (overlaps into body)
            translate([0, 0, -thickness/2 + chamfer_h/2])
                hex_prism(chamfer_h, R);
        }

        // Through-hole (slightly extended to guarantee cut)
        cylinder(h=thickness + 2, d=hole_d, center=true);

        // Chamfer cuts (top and bottom), kept connected via difference
        translate([0, 0, thickness/2 - chamfer_h])
            cylinder(h=chamfer_h + 0.01, r1=R, r2=R - chamfer_inset, $fn=6, center=false);

        translate([0, 0, -thickness/2])
            cylinder(h=chamfer_h + 0.01, r1=R - chamfer_inset, r2=R, $fn=6, center=false);
    }
}

hex_nut();