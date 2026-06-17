// Hex nut: 6.0 mm screw, 7.7 mm across flats, 7.9 mm thick

thread_nominal_diameter_mm = 6.0;   //[3:12:0.1]
across_flats_mm            = 7.7;   //[4:16:0.1]
thickness_mm               = 7.9;   //[4:16:0.1]
tolerance_mm               = 0.0;   //[-0.5:0.8:0.05]
eps_mm                     = 0.2;   //[0.01:1:0.01]

// For a regular hex made with cylinder($fn=6), OpenSCAD's r is the circumradius.
// Across-flats (AF) = sqrt(3) * r  =>  r = AF / sqrt(3)
hex_circumradius_mm = across_flats_mm / sqrt(3);

module hex_nut() {
    hole_r = (thread_nominal_diameter_mm + tolerance_mm) / 2;

    difference() {
        // Hex body (one connected solid)
        cylinder(r = hex_circumradius_mm, h = thickness_mm, center = true, $fn = 6);

        // Through-hole: extend beyond both faces to guarantee a clean cut in all views
        translate([0, 0, 0])
            cylinder(r = hole_r, h = thickness_mm + 2*eps_mm, center = true, $fn = 128);
    }
}

hex_nut();