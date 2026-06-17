// Sheet: carbon fiber (single connected solid)
// Fixes: robust rounded-rectangle sheet, visible thickness, non-blank render, subtle weave-like surface relief

// ---------- Parameters ----------
sheet_L = 300;            // [150:600:1]
sheet_W = 200;            // [100:400:1]
sheet_T = 2;              // [1:6:0.1]
corner_radius = 6;        // [0.5:20:0.1]  // increased default so rounding is visible
edge_chamfer = 0.5;       // [0.0:3:0.1]
overlap = 0.2;            // [0.05:2:0.05]

// Weave relief (pure geometry; OpenSCAD has no true textures)
weave_pitch = 8;          // [4:20:1]
weave_amp   = 0.12;       // [0:0.5:0.01]  // keep small vs thickness
weave_margin = 2;         // [0:10:0.5]

// Quality
$fn = 64;

// ---------- Helpers ----------
function clamp(x, a, b) = x < a ? a : (x > b ? b : x);
r_eff = clamp(corner_radius, 0, min(sheet_L, sheet_W)/2 - 0.01);
ch_eff = clamp(edge_chamfer, 0, sheet_T/2 - 0.001);

// ---------- Base 2D rounded rectangle ----------
module rounded_rect_2d(L, W, r){
    // Robust rounded rectangle using offset (works for r=0 too)
    offset(r=r) square([L-2*r, W-2*r], center=true);
}

// ---------- Main sheet solid (with optional chamfer) ----------
module sheet_solid(){
    // Create a chamfer by hulling two extrusions: bottom full size, top inset by chamfer amount
    // This yields a single connected solid with beveled edges.
    if (ch_eff > 0) {
        hull() {
            translate([0,0,-sheet_T/2])
                linear_extrude(height=overlap)
                    rounded_rect_2d(sheet_L, sheet_W, r_eff);

            translate([0,0, sheet_T/2 - overlap])
                linear_extrude(height=overlap)
                    rounded_rect_2d(sheet_L - 2*ch_eff, sheet_W - 2*ch_eff, max(r_eff - ch_eff, 0));
        }
    } else {
        linear_extrude(height=sheet_T, center=true)
            rounded_rect_2d(sheet_L, sheet_W, r_eff);
    }
}

// ---------- Subtle carbon-fiber weave relief (top surface only) ----------
module weave_relief(){
    // Intersect with the sheet footprint so bumps never extend beyond edges.
    intersection() {
        // Limit to a slightly inset area to avoid edge artifacts
        linear_extrude(height=sheet_T + 2*overlap, center=true)
            rounded_rect_2d(sheet_L - 2*weave_margin, sheet_W - 2*weave_margin, max(r_eff - weave_margin, 0));

        // Place small "ridges" near the top surface
        union() {
            // Two diagonal families to suggest a twill weave
            // Use long thin boxes rotated +/-45 degrees, repeated across the sheet.
            for (a = [-45, 45]) {
                rotate([0,0,a])
                    for (y = [-max(sheet_L,sheet_W) : weave_pitch : max(sheet_L,sheet_W)]) {
                        translate([0, y, sheet_T/2 - weave_amp/2])
                            cube([max(sheet_L,sheet_W)*2, weave_pitch*0.35, weave_amp], center=true);
                    }
            }
        }
    }
}

// ---------- Final Output ----------
color([0.08, 0.08, 0.09])  // dark carbon base
union() {
    sheet_solid();
    if (weave_amp > 0)
        weave_relief();    // adds subtle geometric weave so it doesn't read as flat black
}