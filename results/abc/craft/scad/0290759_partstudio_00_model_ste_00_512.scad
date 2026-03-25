// Rounded-rectangle (square-like) solid block with flat central faces and
// continuous planar chamfers on ALL 12 edges (no taper/draft).
// Bounding box: 0.1 x 0.1 x 0.1 mm

bbox_x = 0.1;
bbox_y = 0.1;
bbox_z = 0.1;

chamfer = 0.01;        // chamfer distance along each adjacent face
corner_facets = 4;     // facets for rounded-rectangle corners (2D)
eps = 1e-6;

$fn = 48;

// --- helpers ---
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// 2D rounded-rectangle made from a hull of circles
module rr2d(w, h, r, facets=corner_facets) {
    r2 = clamp(r, 0, min(w, h)/2);
    if (r2 <= 0)
        square([w, h], center=true);
    else
        hull() {
            for (sx = [-1, 1], sy = [-1, 1])
                translate([sx*(w/2 - r2), sy*(h/2 - r2)])
                    circle(r=r2, $fn=max(16, facets*8));
        }
}

// Main: uniform-thickness block with explicit chamfers (no linear_extrude scaling)
module chamfered_rr_block(size=[bbox_x,bbox_y,bbox_z], c=chamfer, facets=corner_facets) {
    sx = size[0]; sy = size[1]; sz = size[2];

    // keep chamfer valid
    cmax = min(sx, min(sy, sz))/2 - eps;
    cc = clamp(c, 0, cmax);

    // choose a visible but valid corner radius for the base rounded-rectangle
    r_base = clamp(min(sx, sy) * 0.22, 0, min(sx, sy)/2 - eps);

    // small overlap to guarantee watertight unions (scaled to this tiny model)
    ov = min(1e-4, min(sx, min(sy, sz)) * 0.01);

    // If no chamfer requested, just extrude the rounded-rectangle
    if (cc <= 0) {
        linear_extrude(height=sz, center=true, convexity=10)
            rr2d(sx, sy, r_base, facets);
    } else {
        // Core dimensions after removing chamfers on all sides
        core_x = max(eps, sx - 2*cc);
        core_y = max(eps, sy - 2*cc);
        core_z = max(eps, sz - 2*cc);

        // Corner radius for the core profile (reduced so it stays valid)
        r_core = clamp(r_base - cc, 0, min(core_x, core_y)/2 - eps);

        union() {
            // --- Core (flat central face on each side) ---
            // This guarantees parallel opposite faces and identical orthographic views.
            linear_extrude(height=core_z + 2*ov, center=true, convexity=10)
                rr2d(core_x, core_y, r_core, facets);

            // --- Chamfers on top and bottom perimeters (4 long edges + 4 corner transitions) ---
            // Implemented as hull between core and full-size profiles at z = +/- (core_z/2 + cc)
            for (szn = [-1, 1]) {
                hull() {
                    translate([0, 0, szn*(core_z/2 - ov)])
                        linear_extrude(height=2*ov, center=true, convexity=10)
                            rr2d(core_x, core_y, r_core, facets);

                    translate([0, 0, szn*(core_z/2 + cc + ov)])
                        linear_extrude(height=2*ov, center=true, convexity=10)
                            rr2d(sx, sy, r_base, facets);
                }
            }

            // --- Chamfers on the 4 vertical side edges (connect full-size profile down the sides) ---
            // Hull between full-size profile at top and bottom creates planar side chamfers
            // while keeping the mid-height silhouette constant (no taper).
            hull() {
                translate([0, 0,  (core_z/2 + cc - ov)])
                    linear_extrude(height=2*ov, center=true, convexity=10)
                        rr2d(sx, sy, r_base, facets);

                translate([0, 0, -(core_z/2 + cc - ov)])
                    linear_extrude(height=2*ov, center=true, convexity=10)
                        rr2d(sx, sy, r_base, facets);
            }
        }
    }
}

// Render final geometry (single connected solid)
chamfered_rr_block([bbox_x, bbox_y, bbox_z], chamfer, corner_facets);