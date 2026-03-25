// Dimension-calibrated (target: 0.02 x 0.02 x 0.01 mm)
scale([0.601248, 2.004161, 1.739221])
{
// Symmetric plus-shaped (cross) plate: two perpendicular rectangular bars
// intersecting at midpoints, with slight outer-edge chamfer and a subtly
// thickened/rounded center intersection.
// Units are meters (OpenSCAD is unitless).

$fn = 96;

// ---- Parameters ----
arm_len = 0.01;      // full end-to-end length of each bar (X and Y)
arm_w   = 0.006;     // bar width
arm_t   = 0.008;     // arm thickness (plate thickness)

center_size = 0.007; // size of center thickened pad (square)
center_t    = 0.010; // center thickness (slightly thicker than arms)

chamfer = 0.00035;   // small 2D corner bevel approximation
overlap = 0.0015;    // 1–2mm overlap to guarantee watertight union

// ---- Helpers ----
function clamp(x, a, b) = min(max(x, a), b);

module cross_2d() {
    // True plus: two rectangles crossing at midpoints -> four equal arms
    union() {
        square([arm_len, arm_w], center=true); // horizontal bar
        square([arm_w, arm_len], center=true); // vertical bar
    }
}

module chamfered_2d(c) {
    // Corner bevel approximation via in-out offset (keeps silhouette stable)
    cc = clamp(c, 0, arm_w * 0.25);
    offset(delta=cc, join_type="miter")
        offset(delta=-cc, join_type="miter")
            children();
}

module arms_solid() {
    // Flat plate-like cross with consistent small chamfers
    linear_extrude(height=arm_t, center=true, convexity=10)
        chamfered_2d(chamfer)
            cross_2d();
}

module center_pad_solid() {
    // Slightly thickened/rounded center boss; overlaps arms in Z for solid connection
    // Keep it subtle so the planform remains an obvious '+' (not a dominant block).
    r = clamp(chamfer * 1.8, 0, center_size * 0.25);

    // Ensure overlap with arms in Z (no floating): center=true so both share Z=0.
    // Height is slightly extended by overlap to guarantee a watertight union.
    h = center_t + overlap;

    linear_extrude(height=h, center=true, convexity=10)
        offset(r=r)
            square([center_size, center_size], center=true);
}

// ---- Final model (one connected solid) ----
union() {
    // Both solids are centered at origin; no translate() needed, so no risk of gaps.
    arms_solid();
    center_pad_solid();
}
}
