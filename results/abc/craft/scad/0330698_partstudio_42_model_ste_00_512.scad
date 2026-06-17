// Dimension-calibrated (target: 0.06 x 0.10 x 0.01 mm)
scale([0.997015, 0.598209, 5.003214])
{
// Thin stepped mounting plate with 6 diamond (rotated-square) through-holes
// Bounding box target: 0.1 x 0.1 x ~0 (very thin plate)

$fn = 48;

// --- Parameters (mm) ---
bbox_X = 0.10;
bbox_Y = 0.10;
T      = 0.001;          // very thin plate (keeps Z ~ 0.0 in many viewers)

step_depth  = 0.018;     // side notch depth
step_length = 0.028;     // notch length from each end

// Outer corner rounding (2D) and small Z fillet (kept tiny to preserve thinness)
corner_r_2d = 0.004;
z_fillet_r  = 0.00015;

// Holes (diamond appearance = rotated square)
hole_square_side = 0.010;
hole_rotation_deg = 45;
hole_pitch_Y = 0.020;
group_offset_X = 0.028;

// Small overlap for robust boolean cuts
cut_overlap = 0.002;

// --- Helpers ---
module rounded_polygon_2d(pts, r) {
    // Offset out then in to round/chamfer corners in 2D
    // (works well for plate-like parts)
    offset(delta = r) offset(delta = -r) polygon(points = pts);
}

module plate_profile_2d() {
    // Stepped outline: rectangular plate with side notches centered in Y
    // Points are CCW
    pts = [
        [-bbox_X/2, -bbox_Y/2],
        [ bbox_X/2, -bbox_Y/2],
        [ bbox_X/2, -bbox_Y/2 + step_length],
        [ bbox_X/2 - step_depth, -bbox_Y/2 + step_length],
        [ bbox_X/2 - step_depth,  bbox_Y/2 - step_length],
        [ bbox_X/2,  bbox_Y/2 - step_length],
        [ bbox_X/2,  bbox_Y/2],
        [-bbox_X/2,  bbox_Y/2],
        [-bbox_X/2,  bbox_Y/2 - step_length],
        [-bbox_X/2 + step_depth,  bbox_Y/2 - step_length],
        [-bbox_X/2 + step_depth, -bbox_Y/2 + step_length],
        [-bbox_X/2, -bbox_Y/2 + step_length]
    ];

    rounded_polygon_2d(pts, corner_r_2d);
}

module plate_solid() {
    // Keep as a constant-thickness plate; optional tiny Z fillet via minkowski
    // (z_fillet_r is tiny so it still reads as flat)
    if (z_fillet_r > 0) {
        minkowski() {
            linear_extrude(height = max(T - 2*z_fillet_r, 0.0001), center = true)
                plate_profile_2d();
            sphere(r = z_fillet_r);
        }
    } else {
        linear_extrude(height = T, center = true)
            plate_profile_2d();
    }
}

module diamond_hole_tool() {
    rotate([0,0,hole_rotation_deg])
        cube([hole_square_side, hole_square_side, T + 2*cut_overlap], center = true);
}

module holes_all() {
    // Two groups of 3 holes each, symmetric about X=0, centered about Y=0
    for (sx = [-1, 1]) {
        for (iy = [-1, 0, 1]) {
            translate([sx*group_offset_X, iy*hole_pitch_Y, 0])
                diamond_hole_tool();
        }
    }
}

// --- Final model (ONE connected solid) ---
difference() {
    plate_solid();
    holes_all();
}
}
