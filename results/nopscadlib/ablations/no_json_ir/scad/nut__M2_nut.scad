$fn = 96;

// Target dimensions
af = 4.9;          // across flats (mm)
thk = 1.6;         // thickness (mm)
screw_d = 2.0;     // nominal screw diameter (mm)

// Practical clearances / details
hole_d = screw_d + 0.2;   // clearance for M2 (mm)
chamfer_h = 0.25;         // lead-in height per side (mm)
chamfer_inset = 0.25;     // how much the chamfer pulls in from flats (mm)
eps = 0.02;

// Derived radii
r_outer = af / sqrt(3);                 // circumradius for hex with given across-flats
r_outer_ch = (af - 2*chamfer_inset) / sqrt(3);
r_hole = hole_d / 2;

module hex_prism(h, r) {
    cylinder(h=h, r=r, center=true, $fn=6);
}

module hex_nut() {
    difference() {
        union() {
            // Main body
            hex_prism(thk, r_outer);

            // Top chamfer (connected with slight overlap)
            translate([0, 0, thk/2 - chamfer_h/2 + eps/2])
                cylinder(h=chamfer_h + eps, r1=r_outer, r2=r_outer_ch, center=true, $fn=6);

            // Bottom chamfer (connected with slight overlap)
            translate([0, 0, -thk/2 + chamfer_h/2 - eps/2])
                cylinder(h=chamfer_h + eps, r1=r_outer_ch, r2=r_outer, center=true, $fn=6);
        }

        // Through-hole (extends beyond thickness to guarantee cut)
        cylinder(h=thk + 2*(chamfer_h + 1), r=r_hole, center=true);
    }
}

hex_nut();