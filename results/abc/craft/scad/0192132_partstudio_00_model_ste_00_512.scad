// Dimension-calibrated (target: 0.05 x 0.07 x 0.07 mm)
scale([0.700492, 0.700492, 0.510358])
{
// Short solid cylindrical puck/drum with slight fillets and subtle faceting
// Bounding box target: 0.1 x 0.1 x 0.1 mm (max extents)

// --- Parameters (mm) ---
bbox = 0.1;                 // required overall max size in X/Y/Z
body_d = 0.1;               // outer diameter (X/Y)
body_h = 0.1;               // height (Z)
facet_count = 16;           // subtle faceting on outer surface
fillet_r = 0.004;           // edge rounding radius (kept small)

// Safety: keep fillet within half-height and radius
fillet_r_eff = min(fillet_r, body_h/2 - 0.0001, body_d/2 - 0.0001);

// --- Main solid with rounded edges (no holes/cutouts) ---
module filleted_puck(d, h, r, fn_facets) {
    // Use minkowski with a sphere to round edges; compensate so final size matches d/h.
    // Final diameter = (d - 2r) + 2r = d
    // Final height   = (h - 2r) + 2r = h
    minkowski() {
        cylinder(r=(d/2 - r), h=(h - 2*r), center=true, $fn=fn_facets);
        sphere(r=r, $fn=max(24, fn_facets));
    }
}

// Render single connected solid
filleted_puck(body_d, body_h, fillet_r_eff, facet_count);
}
