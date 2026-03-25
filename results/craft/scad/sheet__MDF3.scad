// Sheet MDF (single connected solid)

// Parameters
sheet_length    = 600; //[300:1200:1]
sheet_width     = 400; //[200:800:1]
sheet_thickness = 18;  //[9:36:1]
corner_radius   = 8;   //[2:20:1]
edge_chamfer    = 1.5; //[0.5:4:0.5]
overlap         = 1;   //[0.5:2:0.5]

$fn = 64;

// Helpers
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// Keep radii valid for given sheet size
cr = clamp(corner_radius, 0, min(sheet_length, sheet_width)/2 - 0.01);
ch = clamp(edge_chamfer, 0, min(sheet_length, sheet_width)/2 - cr - 0.01);

// 2D rounded rectangle (robust, non-blank)
module rounded_rect_2d(L, W, R) {
    if (R <= 0) {
        square([L, W], center=true);
    } else {
        hull() {
            for (sx = [-1, 1], sy = [-1, 1])
                translate([sx*(L/2 - R), sy*(W/2 - R)])
                    circle(r=R);
        }
    }
}

// Main solid: MDF sheet with rounded corners and a top edge chamfer
module mdf_sheet() {
    union() {
        // Main body with rounded corners
        linear_extrude(height=sheet_thickness, center=true)
            rounded_rect_2d(sheet_length, sheet_width, cr);

        // Top chamfer ring (connected with slight overlap)
        if (ch > 0) {
            translate([0, 0, sheet_thickness/2 - ch/2])
                linear_extrude(height=ch + overlap, center=true)
                    difference() {
                        rounded_rect_2d(sheet_length, sheet_width, cr);
                        rounded_rect_2d(sheet_length - 2*ch, sheet_width - 2*ch, max(cr - ch, 0));
                    }
        }
    }
}

mdf_sheet();