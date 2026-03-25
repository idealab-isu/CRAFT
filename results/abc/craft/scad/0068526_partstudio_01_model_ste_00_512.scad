// Dimension-calibrated (target: 0.03 x 0.02 x 0.02 mm)
scale([0.001000, 0.001000, 0.001000])
{
// Prismatic U-channel cradle/guide block with:
// - open-top cavity (U-channel) clearly visible from top
// - recessed central pocket (second step down) in the cavity floor
// - slightly tapered inner faces of side walls (draft)
// - chamfered outer top edges (along length)
// - bottom rectangular relief/notch creating a bridge-like underside profile
//
// Structural fixes applied:
// - Cavity tool is an OPEN-TOP cut (no "top face" in polyhedron) so top view shows the opening
// - Bottom notch is cut from underside but clamped to NOT break into cavity floor
// - Pocket is cut from cavity floor downward but clamped to preserve remaining floor
// - All translate() values are derived from L/W/H and feature sizes (no arbitrary offsets)
// - Single connected solid via one base cube and subtractive tools
// - Small overlap used to avoid coplanar artifacts

// ---------- Parameters (mm) ----------
L = 30;                  // overall length (X)
W = 20;                  // overall width  (Y)
H = 20;                  // overall height (Z)

wall_t = 4;              // side wall thickness (each side)

floor_t = 4;             // thickness under main cavity floor (must remain)
cavity_depth = H - floor_t;  // depth of open-top cavity from top down (leaves floor)

taper_per_side = 0.5;    // inner wall taper per side (wider at top by 2*taper)

chamfer = 1;             // outer top edge chamfer size (along the two long top edges)

notch_L = 20;            // bottom relief notch length (X)
notch_W = 12;            // bottom relief notch width  (Y)
notch_H = 8;             // bottom relief notch height (Z, from bottom upward)

pocket_L = 22;           // recessed pocket in cavity floor (X)
pocket_W = 12;           // recessed pocket in cavity floor (Y)
pocket_depth = 2;        // extra depth below cavity floor (Z)

overlap = 0.6;           // boolean overlap (mm) to avoid coplanar artifacts (within 1-2mm)

$fn = 48;

// ---------- Helpers ----------
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// Effective dimensions (kept valid)
floor_t_eff      = clamp(floor_t, 1, H - 1);
cavity_depth_eff = clamp(cavity_depth, 1, H - floor_t_eff);

// Ensure bottom notch does not break into the cavity floor (bridge-like underside)
notch_H_eff      = clamp(notch_H, 0, max(0, floor_t_eff - 1));

// Ensure pocket does not break through the remaining floor
pocket_depth_eff = clamp(pocket_depth, 0, max(0, floor_t_eff - 1));

// Inner opening width at cavity bottom/top (taper in Y with Z)
inner_W_bottom = max(0.5, W - 2*wall_t);
inner_W_top    = max(0.5, inner_W_bottom + 2*taper_per_side);

// ---------- Tools (subtractive solids) ----------
module cavity_tool_open_top() {
    // Open-top cavity with tapered inner faces.
    // IMPORTANT: no "top face" included, so it is a true open cut and reads as a cavity in top view.
    z_top =  H/2 + overlap;
    z_bot =  H/2 - cavity_depth_eff - overlap;

    y_top_p =  inner_W_top/2;
    y_top_n = -inner_W_top/2;
    y_bot_p =  inner_W_bottom/2;
    y_bot_n = -inner_W_bottom/2;

    x_p =  L/2 + overlap;
    x_n = -L/2 - overlap;

    polyhedron(
        points=[
            [x_n, y_top_n, z_top], // 0
            [x_n, y_top_p, z_top], // 1
            [x_n, y_bot_p, z_bot], // 2
            [x_n, y_bot_n, z_bot], // 3
            [x_p, y_top_n, z_top], // 4
            [x_p, y_top_p, z_top], // 5
            [x_p, y_bot_p, z_bot], // 6
            [x_p, y_bot_n, z_bot]  // 7
        ],
        faces=[
            [0,1,2,3],   // x_n side
            [4,7,6,5],   // x_p side
            // NO TOP FACE -> open-top cavity
            [3,2,6,7],   // bottom face (cavity floor surface)
            [0,3,7,4],   // y- inner wall
            [1,5,6,2]    // y+ inner wall
        ],
        convexity=10
    );
}

module pocket_tool() {
    // Extra recessed pocket in the cavity floor (second step down).
    // Starts at cavity floor and goes DOWN by pocket_depth_eff.
    z_cav_floor = H/2 - cavity_depth_eff; // Z of cavity floor plane
    translate([0, 0, z_cav_floor - pocket_depth_eff/2])
        cube([pocket_L + 2*overlap, pocket_W + 2*overlap, pocket_depth_eff + 2*overlap], center=true);
}

module bottom_notch_tool() {
    // Rectangular relief from bottom upward, centered.
    // Clamped so it stays within the bottom floor thickness (bridge-like profile).
    translate([0, 0, -H/2 + notch_H_eff/2])
        cube([notch_L + 2*overlap, notch_W + 2*overlap, notch_H_eff + 2*overlap], center=true);
}

module top_chamfer_tools() {
    // Chamfer ONLY the two long outer top edges (along X) at Y = +/-W/2.
    // Use long rotated prisms that run the full length.
    if (chamfer > 0) {
        translate([0,  W/2 - chamfer/2, H/2 - chamfer/2])
            rotate([45, 0, 0])
                cube([L + 4*overlap, chamfer + 2*overlap, chamfer + 2*overlap], center=true);

        translate([0, -W/2 + chamfer/2, H/2 - chamfer/2])
            rotate([45, 0, 0])
                cube([L + 4*overlap, chamfer + 2*overlap, chamfer + 2*overlap], center=true);
    }
}

// ---------- Main solid ----------
module u_channel_block() {
    difference() {
        // Single connected base solid
        cube([L, W, H], center=true);

        // Subtractions to form the cradle/guide features
        cavity_tool_open_top(); // open-top cavity with tapered inner faces (visible in top view)
        pocket_tool();          // recessed pocket step in the cavity floor
        bottom_notch_tool();    // underside relief (bridge-like)
        top_chamfer_tools();    // chamfered outer top edges
    }
}

// Final model: one connected solid
u_channel_block();
}
