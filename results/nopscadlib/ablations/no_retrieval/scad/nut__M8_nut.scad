$fn = 96;

// Target dimensions
across_flats = 15.0;   // mm
thickness    = 6.5;    // mm
bore_d       = 8.0;    // mm (clearance/nominal as requested)

// Edge detail (simple lead-in chamfers)
chamfer_h = 0.6;       // mm
chamfer_w = 0.6;       // mm
overlap   = 0.2;       // mm (boolean robustness)

// Derived
bore_r = bore_d/2;
hex_R  = across_flats / sqrt(3); // circumradius for a hex with given across-flats

module hex_prism(af, h) {
    R = af / sqrt(3);
    cylinder(h=h, r=R, center=true, $fn=6);
}

module hex_nut(af, h, hole_d, ch_h, ch_w) {
    hole_r = hole_d/2;

    difference() {
        // Body
        hex_prism(af, h);

        // Through hole
        cylinder(h=h + 2*overlap, r=hole_r, center=true);

        // Top lead-in chamfer (wider at the face, tapering to hole)
        translate([0, 0,  h/2 - ch_h/2])
            cylinder(h=ch_h + overlap, r1=hole_r + ch_w, r2=hole_r, center=true);

        // Bottom lead-in chamfer
        translate([0, 0, -h/2 + ch_h/2])
            cylinder(h=ch_h + overlap, r1=hole_r, r2=hole_r + ch_w, center=true);
    }
}

// Render: ONE connected solid (a single nut body with a central hole)
color("Silver")
hex_nut(across_flats, thickness, bore_d, chamfer_h, chamfer_w);