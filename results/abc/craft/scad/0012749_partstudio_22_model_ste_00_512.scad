// Dimension-calibrated (target: 0.05 x 0.05 x 0.01 mm)
scale([0.520008, 0.960015, 1.300218])
{
// Thin rectangular plate with small triangular recessed corner reliefs (top face)

// Parameters (mm)
plate_L = 0.10;          // length
plate_W = 0.05;          // width
plate_T = 0.01;          // thickness
corner_cut_leg = 0.006;  // triangle leg length along edges
corner_cut_depth = 0.003;// recess depth into top face

eps = 0.0005;

// Main Plate Body
module plate_main_body() {
    cube([plate_L, plate_W, plate_T], center=true);
}

// One corner triangular recess (cut into top face)
module corner_relief_cutout(sx, sy) {
    // sx, sy are +/-1 selecting which corner
    x0 = sx * plate_L/2;
    y0 = sy * plate_W/2;

    // Create a local triangle at origin, then move it to the chosen corner.
    // This avoids relying on polygon points far from the origin (which can
    // cause fragile/empty differences at tiny scales).
    translate([x0, y0, plate_T/2 - corner_cut_depth])
        linear_extrude(height=corner_cut_depth + eps, center=false, convexity=10)
            polygon(points=[
                [0, 0],
                [-sx*corner_cut_leg, 0],
                [0, -sy*corner_cut_leg]
            ]);
}

// Final geometry (single connected solid)
difference() {
    plate_main_body();

    // Four corner recesses (top face only)
    corner_relief_cutout( 1,  1);
    corner_relief_cutout(-1,  1);
    corner_relief_cutout(-1, -1);
    corner_relief_cutout( 1, -1);
}
}
