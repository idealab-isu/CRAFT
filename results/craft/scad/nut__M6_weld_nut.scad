// Hex nut for 6.0mm screws
// Target: 7.7mm across flats, 7.9mm thick, through-hole 6.0mm

thread_nominal_diameter_mm = 6; //[3:12:0.1]
across_flats_mm = 7.7;          //[3.85:15.4:0.1]
thickness_mm = 7.9;             //[3.95:15.8:0.1]
bore_diameter_mm = 6;           //[3:12:0.1]

// 0 = clearance/tap representation (smooth cylinder), 1 = cosmetic thread (not used here)
bore_type = 0;                  //[0:1:1]

chamfer_top_mm = 0;             //[0:2:0.1]
chamfer_bottom_mm = 0;          //[0:2:0.1]

// Small epsilon for robust boolean ops (keep tiny to avoid visible artifacts)
eps_mm = 0.02;                  //[0.01:0.2:0.01]

// Optional washer (disabled by default). If enabled, it is fused to nut (one connected solid).
washer_enabled = 0;             //[0:1:1]
washer_outer_diameter_mm = 12;  //[6:24:0.1]
washer_thickness_mm = 1.6;      //[0.8:3.2:0.1]

// Derived
hex_R = across_flats_mm / (2 * cos(30)); // circumradius that yields correct across-flats
bore_r = bore_diameter_mm / 2;

module hex_nut_body() {
    // Hex prism centered at origin
    cylinder(r = hex_R, h = thickness_mm, center = true, $fn = 6);
}

module bore_cut() {
    // High $fn to avoid faceted/stepped appearance
    cylinder(r = bore_r, h = thickness_mm + 2*eps_mm, center = true, $fn = 128);
}

module chamfer_cut(z_sign, chamfer_h) {
    // z_sign: +1 for top, -1 for bottom
    // Use a conical frustum to bevel the outer edge without removing the whole face.
    // Outer radius slightly larger than hex_R to guarantee full intersection.
    zc = z_sign * (thickness_mm/2 - chamfer_h/2);
    translate([0, 0, zc])
        cylinder(
            h = chamfer_h + 2*eps_mm,
            r1 = hex_R + eps_mm,
            r2 = max(hex_R - chamfer_h, 0.01),
            center = true,
            $fn = 96
        );
}

module nut() {
    difference() {
        hex_nut_body();
        bore_cut();

        if (chamfer_top_mm > 0)
            chamfer_cut(+1, chamfer_top_mm);

        if (chamfer_bottom_mm > 0)
            chamfer_cut(-1, chamfer_bottom_mm);
    }
}

module washer_solid() {
    // Washer fused to nut: place directly under nut with slight overlap
    overlap = eps_mm;
    zc = -(thickness_mm/2 + washer_thickness_mm/2 - overlap);
    translate([0, 0, zc])
        difference() {
            cylinder(r = washer_outer_diameter_mm/2, h = washer_thickness_mm, center = true, $fn = 128);
            cylinder(r = bore_r, h = washer_thickness_mm + 2*eps_mm, center = true, $fn = 128);
        }
}

module assembly() {
    if (washer_enabled) {
        union() {
            nut();
            washer_solid();
        }
    } else {
        nut();
    }
}

assembly();