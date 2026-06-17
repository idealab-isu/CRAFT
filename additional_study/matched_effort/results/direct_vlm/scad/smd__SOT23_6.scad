$fn = 64;

size = [3.0, 1.6, 1.05]; // [L, W, H] in mm

// Rounded rectangular prism helper (centered)
module rbox(sz=[1,1,1], r=0.1) {
    r2 = min(r, sz[0]/2, sz[1]/2, sz[2]/2);
    minkowski() {
        cube([sz[0]-2*r2, sz[1]-2*r2, sz[2]-2*r2], center=true);
        sphere(r=r2);
    }
}

module smd_3216(sz=[3.0,1.6,1.05]) {
    L = sz[0];
    W = sz[1];
    H = sz[2];

    // Feature proportions (kept parametric, derived from dimensions)
    term_len = 0.22 * L;                 // end termination length
    term_thk = 0.18 * H;                 // slight bottom thickening
    body_r   = min(0.10*W, 0.08*L, 0.12*H);
    term_r   = body_r * 0.6;

    // Ensure terminations connect to body with a small overlap
    overlap = 0.02;

    union() {
        // Main ceramic body (overall size maintained)
        rbox([L, W, H], r=body_r);

        // End terminations/pads (connected, slightly proud at bottom)
        for (sx = [-1, 1]) {
            translate([sx*(L/2 - term_len/2 + overlap), 0, -(H/2 - term_thk/2)])
                rbox([term_len, W*0.98, term_thk], r=term_r);
        }

        // Subtle top bevel/marking-like ridge (still one solid, no text)
        ridge_len = 0.55 * L;
        ridge_w   = 0.18 * W;
        ridge_h   = 0.06 * H;
        translate([0, 0, H/2 - ridge_h/2])
            rbox([ridge_len, ridge_w, ridge_h], r=min(term_r, ridge_h/2));
    }
}

smd_3216(size);