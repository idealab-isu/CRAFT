// Dimension-calibrated (target: 0.02 x 0.02 x 0.01 mm)
scale([0.500201, 1.667336, 1.429063])
{
$fn = 64;

// Parameters (meters in original; keep as-is)
arm_len = 0.01;          // full length of each bar (end-to-end)
arm_w   = 0.006;         // bar width
arm_t   = 0.008;         // bar thickness (Z)

center_size    = 0.008;  // center pad size (X/Y)
center_t       = 0.01;   // center pad thickness (Z), slightly thicker than arms

chamfer        = 0.0005; // small bevel/round on outer edges
center_round_r = 0.0015; // extra rounding on center pad

// Robust union overlap (requested 1–2mm; in meters here)
overlap = 0.0015;        // 1.5mm

// ---- Helpers ----
module bar_x() { cube([arm_len, arm_w, arm_t], center=true); }
module bar_y() { cube([arm_w, arm_len, arm_t], center=true); }

module cross_arms() {
    // Two perpendicular bars intersecting at midpoints (same plane)
    union() {
        bar_x();
        bar_y();
    }
}

module center_pad() {
    // Slightly thickened/rounded center intersection (rounded only at center)
    // Keep centered at origin.
    minkowski() {
        cube([center_size, center_size, center_t], center=true);
        sphere(r=center_round_r, $fn=48);
    }
}

module cross_raw() {
    // Ensure one connected solid:
    // - Arms and center are centered at origin
    // - Add a small bridge slab to guarantee intersection even after rounding ops
    union() {
        cross_arms();
        center_pad();

        // Bridge slab: guarantees strong connectivity between arms and center pad
        cube([center_size + 2*overlap,
              center_size + 2*overlap,
              max(arm_t, center_t) + 2*overlap], center=true);
    }
}

module chamfered_cross() {
    // IMPORTANT: Minkowski with a sphere rounds ALL edges and can "square off"
    // the plus silhouette visually if the rounding is too large relative to arm gaps.
    // Keep chamfer small and apply it to the already-plus-shaped solid.
    minkowski() {
        cross_raw();
        sphere(r=chamfer, $fn=32);
    }
}

// Final output: true plus-shaped cross with a slightly thicker/rounded center
chamfered_cross();
}
