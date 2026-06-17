// SMD package target overall size: [9.90, 3.90, 1.25] (L, W, H) in mm

$fn = 48;

L = 9.90;
W = 3.90;
H = 1.25;

// Visual/feature parameters (kept small and derived from dimensions)
edge_r = min(0.25, W/6, H/3);          // body edge rounding
pad_len = min(0.90, L*0.12);           // terminal length on each end
pad_thk = min(0.12, H*0.12);           // slight protrusion below body
pad_inset = min(0.15, W*0.06);         // inset from side edges
overlap = 0.02;                        // tiny overlap to ensure manifold union

module rounded_box(size=[10,5,2], r=0.2) {
    // Minkowski rounded rectangular prism, centered
    // Ensures a single solid with smooth edges
    minkowski() {
        cube([size[0]-2*r, size[1]-2*r, size[2]-2*r], center=true);
        sphere(r=r);
    }
}

module smd_package() {
    union() {
        // Main body (centered)
        rounded_box([L, W, H], edge_r);

        // End terminals/pads (connected, slightly protruding below)
        for (sx = [-1, 1]) {
            translate([
                sx * (L/2 - pad_len/2 + overlap),   // computed from L and pad_len
                0,
                -(H/2) - pad_thk/2 + overlap        // computed from H and pad_thk
            ])
            cube([pad_len, W - 2*pad_inset, pad_thk], center=true);
        }
    }
}

smd_package();