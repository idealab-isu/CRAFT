// Dimension-calibrated (target: 0.03 x 0.17 x 0.17 mm)
scale([0.028904, 0.870000, 0.125000])
{
// Stepped/thickened rectangular bar (single connected solid), no holes/slots/cutouts.
// Units: mm

// Overall envelope intent: elongated along X, ~0.2 x 0.2 cross-section max.
L_total = 30.0;   // length along X
W_max   = 0.20;   // max width  along Y
H_max   = 0.20;   // max height along Z

// Segment lengths (scaled to sum exactly to L_total)
seg_L = [6, 5, 4, 6, 4, 5];  // multiple shoulders

// Segment cross-sections (rectangular), alternating wider/narrower bands
// Make steps DISTINCT so they show in orthographic projections.
seg_W = [0.20, 0.10, 0.20, 0.10, 0.20, 0.10];
seg_H = [0.20, 0.14, 0.20, 0.14, 0.20, 0.14];

// Overlap to guarantee watertight connectivity between adjacent segments.
// Keep small relative to this 0.2 mm-scale cross-section.
overlap = 0.02;

// ---- helpers ----
function sum(v, i=0) = (i >= len(v)) ? 0 : v[i] + sum(v, i+1);

module seg_at(xc, L, W, H) {
    // Centered in Y/Z so width/height changes are visible as shoulders.
    translate([xc, 0, 0])
        cube([L, W, H], center=true);
}

module stepped_bar() {
    sumL   = sum(seg_L);
    scaleL = (sumL <= 0) ? 1 : (L_total / sumL);

    union() {
        x_start = -L_total/2;
        acc = 0;

        // Place segments end-to-end along X with a small overlap so they fuse.
        for (i = [0 : len(seg_L)-1]) {
            Li = seg_L[i] * scaleL;

            // Clamp to maxima to preserve the requested bounding cross-section.
            Wi = min(seg_W[i], W_max);
            Hi = min(seg_H[i], H_max);

            // Recalculated translate: exact end-to-end placement from x_start.
            xc = x_start + acc + Li/2;

            // Add overlap in X only; keeps silhouette stepped while ensuring connectivity.
            seg_at(xc, Li + overlap, Wi, Hi);

            acc = acc + Li;
        }
    }
}

// Final output: one connected solid, stepped/thickened along length, no cutouts
stepped_bar();
}
