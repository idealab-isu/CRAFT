// Sheet MDF (single connected solid with rounded corners + top-edge chamfer)

// Parameters
sheet_L = 600; //[300:1200:1]
sheet_W = 400; //[200:800:1]
sheet_T = 18;  //[9:36:1]
corner_R = 10; //[2:30:1]
chamfer_C = 2; //[0.5:6:0.5]
overlap = 1;   //[0.5:2:0.5]

$fn = 96;

// MDF-like color (visual only)
mdf_col = [0.78, 0.70, 0.55];

// Helpers
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

corner_R_eff = clamp(corner_R, 0, min(sheet_L, sheet_W)/2 - 0.01);
chamfer_eff  = clamp(chamfer_C, 0, sheet_T/2 - 0.01);

// 2D rounded rectangle (centered)
module rounded_rect_2d(L, W, R) {
    if (R <= 0)
        square([L, W], center=true);
    else
        hull() {
            for (sx = [-1, 1], sy = [-1, 1])
                translate([sx*(L/2 - R), sy*(W/2 - R)])
                    circle(r=R);
        }
}

// Main sheet with rounded corners
module mdf_sheet() {
    linear_extrude(height=sheet_T, center=true, convexity=10)
        rounded_rect_2d(sheet_L, sheet_W, corner_R_eff);
}

// Top-edge chamfer cutter (removes a thin band around perimeter on top face)
module top_edge_chamfer_cutter() {
    if (chamfer_eff > 0) {
        // Outer profile slightly larger than sheet; inner profile slightly smaller.
        // The difference creates a perimeter "ring" that we extrude and subtract.
        outer_L = sheet_L + 2*(chamfer_eff + overlap);
        outer_W = sheet_W + 2*(chamfer_eff + overlap);
        inner_L = sheet_L - 2*(chamfer_eff - overlap);
        inner_W = sheet_W - 2*(chamfer_eff - overlap);

        translate([0, 0, sheet_T/2 - chamfer_eff/2])
            linear_extrude(height=chamfer_eff + 2*overlap, center=true, convexity=10)
                difference() {
                    rounded_rect_2d(outer_L, outer_W, corner_R_eff + chamfer_eff + overlap);
                    rounded_rect_2d(inner_L, inner_W, max(corner_R_eff - chamfer_eff, 0));
                }
    }
}

// Final Output
color(mdf_col)
difference() {
    mdf_sheet();
    top_edge_chamfer_cutter();
}