// Hex nut: 4.0mm screw, 5.3mm across flats, 6.3mm thick

$fn = 96;

// Critical dimensions
nut_af   = 5.3;   // across flats (mm)
nut_thk  = 6.3;   // thickness (mm)
hole_d   = 4.0;   // through-hole diameter for 4.0mm screw (mm)

// Edge chamfer (simple 45° bevel approximation)
chamfer_h = 0.4;  // chamfer height (mm)

// Robust boolean overlap
overlap = 0.2;

// Derived geometry
hex_R = nut_af / sqrt(3);                 // circumradius for given across-flats
chamfer_R = max(0, hex_R - chamfer_h);    // smaller hex for chamfer cut

module hex_prism(R, h) {
    linear_extrude(height=h, center=true)
        polygon(points=[
            [ R, 0],
            [ R/2,  R*sqrt(3)/2],
            [-R/2,  R*sqrt(3)/2],
            [-R, 0],
            [-R/2, -R*sqrt(3)/2],
            [ R/2, -R*sqrt(3)/2]
        ]);
}

module nut() {
    difference() {
        // Outer body
        hex_prism(hex_R, nut_thk);

        // Through hole (guaranteed to cut through)
        cylinder(d=hole_d, h=nut_thk + 2*overlap, center=true);

        // Top chamfer cut (removes a ring near the top face)
        translate([0, 0,  nut_thk/2 - chamfer_h/2])
            difference() {
                hex_prism(hex_R + overlap, chamfer_h + overlap);
                hex_prism(chamfer_R,       chamfer_h + 2*overlap);
            }

        // Bottom chamfer cut
        translate([0, 0, -nut_thk/2 + chamfer_h/2])
            difference() {
                hex_prism(hex_R + overlap, chamfer_h + overlap);
                hex_prism(chamfer_R,       chamfer_h + 2*overlap);
            }
    }
}

color("Silver") nut();