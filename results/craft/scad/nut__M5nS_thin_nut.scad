// Thin hex nut for 5.0mm screws, 8.0mm across flats, 2.7mm thick

thread_nominal_diameter_mm = 5.0;   //[2.5:10.0:0.1]
across_flats_mm            = 8.0;   //[6.0:16.0:0.1]
thickness_mm               = 2.7;   //[1.5:6.0:0.1]

// Hole: 0 = clearance, 1 = tap-drill (thread representation)
hole_type                  = 0;     //[0:1:1]
clearance_add_mm           = 0.4;   //[0.0:1.0:0.05]
tap_drill_factor           = 0.85;  //[0.7:0.95:0.01]

// Edge break (optional)
chamfer_mm                 = 0.3;   //[0.0:1.0:0.05]

// Robust boolean epsilon
eps_mm                     = 0.05;  //[0.01:0.2:0.01]

function hole_d_mm() =
    (hole_type == 1)
        ? (thread_nominal_diameter_mm * tap_drill_factor)
        : (thread_nominal_diameter_mm + clearance_add_mm);

module thin_hex_nut() {
    // Hex radius from across-flats: AF = 2 * r * cos(30)
    hex_r = across_flats_mm / (2 * cos(30));
    hole_r = hole_d_mm() / 2;

    difference() {
        // Hex body only (no washer/flange)
        cylinder(r = hex_r, h = thickness_mm, center = true, $fn = 6);

        // Circular hole (high $fn to avoid polygonal look)
        cylinder(r = hole_r, h = thickness_mm + 2*eps_mm, center = true, $fn = 96);

        // Small chamfer/edge break at hole (kept within thickness)
        if (chamfer_mm > 0) {
            chamfer_h = min(chamfer_mm, thickness_mm/2);

            translate([0, 0,  thickness_mm/2 - chamfer_h/2])
                cylinder(r1 = hole_r + chamfer_h, r2 = hole_r,
                         h = chamfer_h + eps_mm, center = true, $fn = 96);

            translate([0, 0, -thickness_mm/2 + chamfer_h/2])
                cylinder(r1 = hole_r, r2 = hole_r + chamfer_h,
                         h = chamfer_h + eps_mm, center = true, $fn = 96);
        }
    }
}

thin_hex_nut();