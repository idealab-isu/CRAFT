// Hex nut for 4.0mm screw, 5.3mm across flats, 6.3mm thick

thread_diameter_mm = 4.0;                 // screw nominal
across_flats_mm = 5.3;                    // required AF
thickness_mm = 6.3;                       // required thickness
clearance_hole_diameter_mm = 4.3;         // through-hole clearance
chamfer_mm = 0.3;                         // small entry chamfer
eps_mm = 0.02;                            // numerical robustness

// Derived: circumradius for a hex with given across-flats
hex_R = across_flats_mm / sqrt(3);        // AF = sqrt(3)*R

module hex_nut() {
    difference() {
        // Outer hex body (single solid)
        cylinder(h = thickness_mm, r = hex_R, $fn = 6, center = true);

        // Through-hole
        cylinder(h = thickness_mm + 2*eps_mm, r = clearance_hole_diameter_mm/2, $fn = 64, center = true);

        // Top chamfer (countersink-like)
        translate([0, 0, thickness_mm/2 - chamfer_mm/2])
            cylinder(h = chamfer_mm + eps_mm,
                     r1 = clearance_hole_diameter_mm/2 + chamfer_mm,
                     r2 = clearance_hole_diameter_mm/2,
                     $fn = 64, center = true);

        // Bottom chamfer
        translate([0, 0, -thickness_mm/2 + chamfer_mm/2])
            cylinder(h = chamfer_mm + eps_mm,
                     r1 = clearance_hole_diameter_mm/2,
                     r2 = clearance_hole_diameter_mm/2 + chamfer_mm,
                     $fn = 64, center = true);
    }
}

hex_nut();