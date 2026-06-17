// Thin hex nut: M4 (4.0mm screw), 7.0mm across flats, 2.2mm thick

thread_nominal_diameter_mm = 4.0;   //[2.0:8.0:0.1]
across_flats_mm           = 7.0;   //[3.5:14.0:0.1]
thickness_mm              = 2.2;   //[1.1:4.4:0.1]
tolerance_mm              = 0.15;  //[0.05:0.4:0.01]
edge_chamfer_mm           = 0.2;   //[0.0:0.6:0.05]
eps_mm                    = 0.02;  //[0.01:0.2:0.01]

// Derived geometry
hex_inradius_mm      = across_flats_mm / 2;                 // center to flat
hex_circumradius_mm  = hex_inradius_mm / cos(30);           // center to corner
hole_diameter_mm     = thread_nominal_diameter_mm + tolerance_mm;

module hex_prism(h) {
    // Use built-in 6-sided cylinder; r is circumradius
    cylinder(h = h, r = hex_circumradius_mm, $fn = 6, center = true);
}

module through_hole(h) {
    cylinder(h = h, r = hole_diameter_mm/2, $fn = 64, center = true);
}

module chamfer_cut(zsign) {
    // Subtractive frustum to create a small edge chamfer on top/bottom
    // zsign = +1 (top) or -1 (bottom)
    translate([0, 0, zsign*(thickness_mm/2 - edge_chamfer_mm/2)])
        cylinder(
            h  = edge_chamfer_mm + 2*eps_mm,
            r1 = hex_circumradius_mm + 2*eps_mm,
            r2 = max(hex_circumradius_mm - edge_chamfer_mm, 0.01),
            $fn = 6,
            center = true
        );
}

difference() {
    hex_prism(thickness_mm);

    // Central through-hole
    through_hole(thickness_mm + 2*eps_mm);

    // Optional top/bottom chamfers (kept small; no protrusions)
    if (edge_chamfer_mm > 0) {
        chamfer_cut(+1);
        chamfer_cut(-1);
    }
}