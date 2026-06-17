$fn = 64;

size = [8.70, 3.90, 1.25]; // [L, W, H]

module smd(sz=[8.70, 3.90, 1.25]) {
    L = sz[0];
    W = sz[1];
    H = sz[2];

    // Feature proportions (kept within overall envelope)
    term_len = min(0.90, L*0.12);     // end termination length
    term_th  = min(0.18, H*0.18);     // termination thickness (bottom)
    chamfer  = min(0.35, H*0.22);     // top edge chamfer height
    notch_r  = min(0.35, W*0.12);     // polarity/ID notch radius
    overlap  = 0.02;                  // tiny overlap to ensure manifold union

    // Body core dimensions (so terminations fit inside total L and H)
    bodyL = L - 2*term_len;
    bodyH = H - term_th;

    union() {
        // Main body with slight top chamfer (via hull of two rectangles)
        translate([0, 0, term_th + bodyH/2])
            hull() {
                // Bottom of body (full body footprint)
                translate([0, 0, -bodyH/2])
                    cube([bodyL, W, overlap], center=true);

                // Top of body (slightly inset to create chamfer)
                translate([0, 0, bodyH/2 - chamfer])
                    cube([max(bodyL - 2*chamfer, overlap),
                          max(W - 2*chamfer, overlap),
                          overlap], center=true);
            }

        // End terminations/pads (connected, slightly overlapping into body)
        for (sx = [-1, 1]) {
            translate([sx*(bodyL/2 + term_len/2 - overlap/2), 0, term_th/2])
                cube([term_len + overlap, W, term_th], center=true);
        }

        // Small top corner notch (subtle ID feature) made as a positive bump
        // (keeps model a single connected solid; provides a visual cue)
        translate([-(bodyL/2 - notch_r), (W/2 - notch_r), term_th + bodyH - notch_r])
            sphere(r=notch_r);
    }
}

smd(size);