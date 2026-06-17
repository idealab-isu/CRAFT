// Plain hex nut: M6 (6.0mm screw), 11.5mm across flats, 5.0mm thick

thread_nominal_diameter_mm = 6.0;   // screw nominal diameter
across_flats_mm            = 11.5;  // AF
thickness_mm               = 5.0;   // nut thickness

// Hole sizing (simple cylindrical hole; not modeled threads)
tolerance_mm               = 0.15;  // added to hole diameter
clearance_extra_mm         = 0.0;   // set >0 for clearance fit
tap_drill_offset_mm        = 1.0;   // used only if hole_type_threaded_flag=1
hole_type_threaded_flag    = 0;     // 0=clearance hole, 1=tap-drill hole

// Edge treatment
chamfer_mm                 = 0.3;   // small chamfer on both faces
eps_mm                     = 0.2;

module hex_nut() {
    hex_R = across_flats_mm / (2 * cos(30)); // circumradius from across-flats
    hole_d = (hole_type_threaded_flag == 1)
        ? (thread_nominal_diameter_mm - tap_drill_offset_mm + tolerance_mm)
        : (thread_nominal_diameter_mm + clearance_extra_mm + tolerance_mm);

    difference() {
        // Outer hex body
        cylinder(r=hex_R, h=thickness_mm, center=true, $fn=6);

        // Through hole
        cylinder(d=hole_d, h=thickness_mm + 2*eps_mm, center=true, $fn=64);

        // Chamfers (remove material at both faces)
        if (chamfer_mm > 0) {
            // Top chamfer
            translate([0, 0, thickness_mm/2 - chamfer_mm/2])
                cylinder(h=chamfer_mm + eps_mm,
                         r1=hex_R + eps_mm,
                         r2=hex_R - chamfer_mm,
                         center=true, $fn=6);

            // Bottom chamfer
            translate([0, 0, -thickness_mm/2 + chamfer_mm/2])
                cylinder(h=chamfer_mm + eps_mm,
                         r1=hex_R - chamfer_mm,
                         r2=hex_R + eps_mm,
                         center=true, $fn=6);
        }
    }
}

hex_nut();