// Dimension-calibrated (target: 0.18 x 0.13 x 0.01 mm)
scale([0.920000, 1.330000, 10.000000])
{
// Thin rectangular plate with rounded outer corners and 4 rotated polygonal corner cutouts
// Target bounding box: 0.2 x 0.1 x (very thin) mm

$fn = 64;

// --- Parameters (mm) ---
plate_L = 0.20;
plate_W = 0.10;

// "0.0 mm" thickness is not a valid solid; use an extremely thin but nonzero thickness
plate_T = 0.001;

corner_R = 0.008;          // outer corner radius
cutout_sides = 6;          // polygonal through-hole
cutout_flat_d = 0.020;     // across diameter (approx)
cutout_rot_deg = 30;       // rotation of the polygon
cutout_offset_x = 0.018;   // from outer edge toward center
cutout_offset_y = 0.018;

eps = 0.01;                // boolean robustness

// --- Helpers ---
module rounded_rect_2d(L, W, R) {
    R2 = min(R, min(L, W)/2);
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(L/2 - R2), sy*(W/2 - R2)])
                circle(r=R2);
    }
}

module plate_solid() {
    linear_extrude(height=plate_T, center=true)
        rounded_rect_2d(plate_L, plate_W, corner_R);
}

module corner_cutout_at(sx, sy) {
    // Place cutout near each corner using dimension-based formulas
    x = sx*(plate_L/2 - cutout_offset_x);
    y = sy*(plate_W/2 - cutout_offset_y);

    translate([x, y, 0])
        rotate([0, 0, cutout_rot_deg])
            cylinder(h=plate_T + 2*eps, r=cutout_flat_d/2, center=true, $fn=cutout_sides);
}

// --- Final ---
difference() {
    plate_solid();

    // Four identical corner cutouts/through-holes
    corner_cutout_at( 1,  1);
    corner_cutout_at(-1,  1);
    corner_cutout_at(-1, -1);
    corner_cutout_at( 1, -1);
}
}
