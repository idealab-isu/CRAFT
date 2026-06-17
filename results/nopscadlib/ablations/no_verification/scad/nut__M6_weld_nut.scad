// Plain hex nut (no flange/washer)
// Target: M6 clearance hole, 7.7mm across flats, 7.9mm thick

thread_nominal_diameter_mm = 6;      //[3:12:0.1]
across_flats_mm = 7.7;               //[3.85:15.4:0.1]
thickness_mm = 7.9;                  //[3.95:15.8:0.1]
clearance_diameter_mm = 6;           //[3:12:0.1]
chamfer_mm = 0.3;                    //[0.0:1:0.05]
overlap_mm = 0.2;                    //[0.05:1:0.05]

// Derived
hex_R = across_flats_mm / (2 * cos(30)); // circumradius for $fn=6 cylinder

module hex_nut_plain() {
    difference() {
        // Outer hex body
        cylinder(r=hex_R, h=thickness_mm, center=true, $fn=6);

        // Through hole (clearance)
        cylinder(r=clearance_diameter_mm/2, h=thickness_mm + 2*overlap_mm, center=true, $fn=64);

        // Optional chamfers on both faces (kept small; does not add flange)
        if (chamfer_mm > 0) {
            // Top chamfer cut
            translate([0, 0, thickness_mm/2 - chamfer_mm/2])
                cylinder(
                    r1=hex_R + overlap_mm,
                    r2=hex_R - chamfer_mm,
                    h=chamfer_mm + overlap_mm,
                    center=true,
                    $fn=6
                );

            // Bottom chamfer cut
            translate([0, 0, -thickness_mm/2 + chamfer_mm/2])
                cylinder(
                    r1=hex_R - chamfer_mm,
                    r2=hex_R + overlap_mm,
                    h=chamfer_mm + overlap_mm,
                    center=true,
                    $fn=6
                );
        }
    }
}

hex_nut_plain();