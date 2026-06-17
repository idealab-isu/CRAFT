// Hex nut: 5.0mm screw, 9.2mm across flats, 4.0mm thick
// One connected solid (nut only)

// Parameters (fixed to requested dimensions)
thread_nominal_diameter_mm = 5.0;
across_flats_mm            = 9.2;
thickness_mm               = 4.0;

// Practical modeling parameters
hole_diameter_mm = thread_nominal_diameter_mm; // simple through-hole representation
edge_chamfer_mm  = 0.3;                        // small edge break on hole
overcut_mm       = 0.2;                        // ensures clean boolean cuts
$fn = 96;

module hex_nut(af, h, hole_d, chamfer) {
    // For a hex made with cylinder($fn=6), r is circumradius.
    // Across flats = 2 * r * cos(30deg)  => r = af / (2*cos(30))
    hex_r = af / (2 * cos(30));

    difference() {
        // Nut body
        cylinder(r=hex_r, h=h, center=true, $fn=6);

        // Through hole
        cylinder(d=hole_d, h=h + 2*overcut_mm, center=true, $fn=96);

        // Hole chamfers (top and bottom), kept within nut thickness
        chamfer_h = min(chamfer, h/2 - 0.01);

        if (chamfer_h > 0) {
            // Top chamfer
            translate([0, 0,  h/2 - chamfer_h/2])
                cylinder(d1=hole_d + 2*chamfer_h, d2=hole_d,
                         h=chamfer_h + overcut_mm, center=true, $fn=96);

            // Bottom chamfer
            translate([0, 0, -h/2 + chamfer_h/2])
                cylinder(d1=hole_d, d2=hole_d + 2*chamfer_h,
                         h=chamfer_h + overcut_mm, center=true, $fn=96);
        }
    }
}

hex_nut(across_flats_mm, thickness_mm, hole_diameter_mm, edge_chamfer_mm);