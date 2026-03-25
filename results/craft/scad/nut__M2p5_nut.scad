// Hex nut for M2.5
thread_nominal_diameter_mm = 2.5;
across_flats_mm = 5.8;
thickness_mm = 2.2;

// Printing/fit
tolerance_mm = 0.10;     // added to hole diameter
edge_chamfer_mm = 0.20;  // lead-in chamfer height
overlap_mm = 0.20;       // boolean overlap to avoid artifacts

// Derived
hex_circumradius_mm = across_flats_mm / sqrt(3); // R such that across-flats = sqrt(3)*R
hole_r_mm = (thread_nominal_diameter_mm + tolerance_mm) / 2;

module hex_nut() {
    difference() {
        // Clean hex body (flat-to-flat = across_flats_mm)
        cylinder(r = hex_circumradius_mm, h = thickness_mm, center = true, $fn = 6);

        // Circular through-hole
        cylinder(r = hole_r_mm, h = thickness_mm + 2*overlap_mm, center = true, $fn = 96);

        // Lead-in chamfers (top and bottom), kept within thickness
        translate([0, 0,  thickness_mm/2 - edge_chamfer_mm/2])
            cylinder(r1 = hole_r_mm + edge_chamfer_mm, r2 = hole_r_mm,
                     h = edge_chamfer_mm + overlap_mm, center = true, $fn = 96);

        translate([0, 0, -thickness_mm/2 + edge_chamfer_mm/2])
            cylinder(r1 = hole_r_mm, r2 = hole_r_mm + edge_chamfer_mm,
                     h = edge_chamfer_mm + overlap_mm, center = true, $fn = 96);
    }
}

hex_nut();