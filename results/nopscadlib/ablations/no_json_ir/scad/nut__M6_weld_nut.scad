$fn = 120;

// Requested dimensions
af     = 7.7;   // across flats (mm)
thk    = 7.9;   // thickness (mm)
hole_d = 6.0;   // screw size / clearance (mm)

// Small modeling tolerances
eps     = 0.02;
chamfer = 0.6;  // edge chamfer height (mm)

// Connectivity overlap (1–2mm as required)
ov = 1.0;

// 2D hex profile (across-flats)
module hex2d(af_dim) {
    Rloc = af_dim / sqrt(3);
    polygon(points=[
        [ Rloc, 0],
        [ Rloc/2,  Rloc*sqrt(3)/2],
        [-Rloc/2,  Rloc*sqrt(3)/2],
        [-Rloc, 0],
        [-Rloc/2, -Rloc*sqrt(3)/2],
        [ Rloc/2, -Rloc*sqrt(3)/2]
    ]);
}

module hex_nut() {

    // Build as a single connected solid, then subtract the hole
    difference() {
        union() {
            // Main body (straight section)
            linear_extrude(height = thk - 2*chamfer, center = true)
                hex2d(af);

            // Top chamfer (overlap into main body by ov)
            translate([0, 0, (thk/2 - chamfer/2 - ov/2)])
                linear_extrude(
                    height = chamfer + ov,
                    center = true,
                    scale  = (af - 2*chamfer)/af
                )
                    hex2d(af);

            // Bottom chamfer (overlap into main body by ov)
            translate([0, 0, -(thk/2 - chamfer/2 - ov/2)])
                linear_extrude(
                    height = chamfer + ov,
                    center = true,
                    scale  = (af - 2*chamfer)/af
                )
                    hex2d(af);

            // NOTE:
            // The reported "floating thin flange/washer-like ring pieces" and
            // "thin plate-like slivers" are typical artifacts from coplanar/
            // barely-touching chamfer extrusions. The ov overlap above forces
            // real intersection (1mm) so no disconnected rings/slivers remain.
        }

        // Central through-hole
        cylinder(h = thk + 2*eps, d = hole_d, center = true);
    }
}

hex_nut();