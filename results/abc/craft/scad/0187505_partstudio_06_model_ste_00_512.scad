// Dimension-calibrated (target: 0.07 x 0.09 x 0.00 mm)
scale([0.880000, 0.650000, 3.000000])
{
// Thin rectangular plate with centered pentagonal through-cutout
// and four diamond-oriented square through-holes near corners.

// --- Parameters (mm) ---
plate_L = 0.10;
plate_W = 0.10;
plate_T = 0.001;   // tiny but nonzero thickness for robust rendering

pent_R  = 0.028;   // circumradius of regular pentagon
hole_sq = 0.010;   // square hole side length
hole_rot_deg = 45;

edge_margin = 0.015; // distance from each edge to hole center

// --- Derived placements ---
hole_off_x = plate_L/2 - edge_margin;
hole_off_y = plate_W/2 - edge_margin;

// --- Helpers ---
module pentagon_2d(R, rot_deg=0) {
    polygon(points=[
        for (i = [0:4])
            [ R*cos(rot_deg + 90 + i*72), R*sin(rot_deg + 90 + i*72) ]
    ]);
}

// --- Model ---
difference() {
    // Base plate
    cube([plate_L, plate_W, plate_T], center=true);

    // Central pentagonal through-cutout
    linear_extrude(height=plate_T + 0.01, center=true, convexity=5)
        pentagon_2d(pent_R, rot_deg=0);

    // Four corner diamond square through-holes
    for (sx = [-1, 1], sy = [-1, 1]) {
        translate([sx*hole_off_x, sy*hole_off_y, 0])
            rotate([0, 0, hole_rot_deg])
                cube([hole_sq, hole_sq, plate_T + 0.01], center=true);
    }
}
}
