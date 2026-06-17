// Hex nut for M2.5 screw
af = 5.8;          // across flats (mm)
thk = 2.2;         // thickness (mm)
hole_d = 2.5;      // clearance hole (mm)
chamfer_h = 0.2;   // chamfer height (mm)
chamfer_af = 5.4;  // chamfer across flats (mm)

eps = 0.02;

module hex_prism(af_dim, h_dim) {
    // For $fn=6, cylinder(d=...) is across corners.
    // Convert across-flats to across-corners: d_corners = af / cos(30°)
    d_corners = af_dim / cos(30);
    cylinder(d = d_corners, h = h_dim, $fn = 6);
}

difference() {
    union() {
        // Main body
        hex_prism(af, thk);

        // Top chamfer (overlaps into body to ensure one connected solid)
        translate([0, 0, thk - chamfer_h + eps])
            hex_prism(af, chamfer_h);

        // Bottom chamfer (overlaps into body)
        translate([0, 0, -eps])
            hex_prism(af, chamfer_h);
    }

    // Through hole (extends beyond part to guarantee full cut)
    translate([0, 0, -1])
        cylinder(d = hole_d, h = thk + 2, $fn = 64);

    // Chamfer cuts (lead-in) top and bottom
    translate([0, 0, thk - chamfer_h])
        hex_prism(chamfer_af, chamfer_h + 1);

    translate([0, 0, -1])
        hex_prism(chamfer_af, chamfer_h + 1);
}