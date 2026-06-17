// Sheet DiBond - single connected solid with rounded corners and mounting holes

// Parameters
sheet_length = 1000; //[500:2000:1]
sheet_width = 500;   //[250:1000:1]
sheet_thickness = 3; //[1.5:6:0.1]
corner_radius = 10;  //[2:25:1]
hole_diameter = 6;   //[3:12:0.5]
hole_edge_offset = 25; //[10:80:1]

// Robustness / connectivity
eps = 0.05;          // small overlap to avoid coplanar artifacts
$fn = 96;

// Helpers
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// Keep features valid
r = clamp(corner_radius, 0, min(sheet_length, sheet_width)/2 - eps);
hole_off = clamp(
    hole_edge_offset,
    hole_diameter/2 + eps,
    min(sheet_length, sheet_width)/2 - r - eps
);

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

// Main sheet with holes (single solid)
module sheet_dibond() {
    difference() {
        // Use center=false so Z spans [0..thickness] (avoids "blank" renders in some pipelines)
        linear_extrude(height=sheet_thickness, center=false, convexity=20)
            rounded_rect_2d(sheet_length, sheet_width, r);

        // Mounting holes (through), slightly longer than thickness for clean subtraction
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(sheet_length/2 - hole_off), sy*(sheet_width/2 - hole_off), -eps])
                cylinder(h=sheet_thickness + 2*eps, r=hole_diameter/2, center=false);
    }
}

sheet_dibond();