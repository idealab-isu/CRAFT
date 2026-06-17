// Thin hex nut for 4.0mm screws: 7.0mm across flats, 2.2mm thick
// One connected solid (nut only), true hex across flats, clean geometry.

// Parameters
thread_nominal_diameter_mm = 4.0;   // screw size (nominal)
across_flats_mm            = 7.0;   // hex across flats
thickness_mm               = 2.2;   // nut thickness

// Hole (choose a sensible default for M4 clearance; adjust if you want tapped/minor)
hole_diameter_mm           = 4.3;   // clearance for M4 (typical)

// Small edge break (kept subtle to avoid artifacts)
chamfer_mm                 = 0.15;  // small chamfer on both faces

eps_mm                     = 0.02;  // numerical epsilon

// Derived: for a regular hex, across_flats = 2 * apothem.
// OpenSCAD cylinder(r=..., $fn=6) uses r as circumradius.
// circumradius = apothem / cos(30) = (across_flats/2) / cos(30)
hex_R = (across_flats_mm/2) / cos(30);

// 2D hex profile with exact across-flats
module hex2d(af) {
    R = (af/2) / cos(30);
    polygon(points=[for (i=[0:5]) [R*cos(60*i), R*sin(60*i)]]);
}

module thin_hex_nut() {
    difference() {
        // Outer body with small chamfers (no rounding of flats)
        union() {
            // Middle prismatic section
            linear_extrude(height = max(thickness_mm - 2*chamfer_mm, 0), center=true)
                hex2d(across_flats_mm);

            // Top chamfer (tapers inward)
            if (chamfer_mm > 0)
                translate([0,0, (thickness_mm/2) - chamfer_mm/2])
                    linear_extrude(height=chamfer_mm, center=true, scale=(across_flats_mm - 2*chamfer_mm)/across_flats_mm)
                        hex2d(across_flats_mm);

            // Bottom chamfer (tapers inward)
            if (chamfer_mm > 0)
                translate([0,0, -(thickness_mm/2) + chamfer_mm/2])
                    linear_extrude(height=chamfer_mm, center=true, scale=(across_flats_mm - 2*chamfer_mm)/across_flats_mm)
                        hex2d(across_flats_mm);
        }

        // Through hole
        cylinder(d=hole_diameter_mm, h=thickness_mm + 2*eps_mm, center=true, $fn=64);
    }
}

thin_hex_nut();