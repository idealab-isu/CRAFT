// Thin hex nut for M3 screw
thread_nominal_diameter_mm = 3.0; //[1.5:6.0:0.1]
across_flats_mm = 5.5;            //[3.0:11.0:0.1]
thickness_mm = 1.8;               //[0.9:3.6:0.1]
clearance_hole_diameter_mm = 3.2; //[2.8:4.5:0.1]
chamfer_mm = 0.2;                 //[0.0:0.6:0.05]
tolerance_mm = 0.1;               //[0.0:0.3:0.05]
overlap_mm = 0.8;                 //[0.5:2.0:0.1]

$fn = 96;

// Convert across-flats to circumradius for a regular hex:
// across_flats = 2 * apothem, apothem = R * cos(30°) => R = across_flats / sqrt(3)
hex_circumradius_mm = across_flats_mm / sqrt(3);

// Use a circular clearance hole suitable for M3
hole_diameter_mm = clearance_hole_diameter_mm + tolerance_mm;

module thin_hex_nut() {
    difference() {
        // Hex body
        cylinder(r = hex_circumradius_mm, h = thickness_mm, center = true, $fn = 6);

        // Round through-hole
        cylinder(d = hole_diameter_mm, h = thickness_mm + 2*overlap_mm, center = true, $fn = 96);

        // Small edge chamfers (top and bottom), kept subtle to avoid creating a flange
        if (chamfer_mm > 0) {
            // Top chamfer
            translate([0, 0, thickness_mm/2 - chamfer_mm/2])
                cylinder(r1 = hex_circumradius_mm + overlap_mm,
                         r2 = hex_circumradius_mm - chamfer_mm,
                         h  = chamfer_mm + overlap_mm,
                         center = true, $fn = 6);

            // Bottom chamfer
            translate([0, 0, -thickness_mm/2 + chamfer_mm/2])
                cylinder(r1 = hex_circumradius_mm - chamfer_mm,
                         r2 = hex_circumradius_mm + overlap_mm,
                         h  = chamfer_mm + overlap_mm,
                         center = true, $fn = 6);
        }
    }
}

thin_hex_nut();