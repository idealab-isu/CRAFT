// Dimension-calibrated (target: 0.07 x 0.09 x 0.00 mm)
scale([0.880014, 0.650010, 3.001651])
{
// Thin rectangular plate with centered pentagonal through-cutout
// and four diamond-oriented square through-holes near corners.

// Use a small but nonzero thickness so geometry is visible/robust.
plate_L = 0.1;
plate_W = 0.1;
plate_T = 0.001;

// Cutouts
pent_R = 0.022;          // circumradius of pentagon
pent_rot_deg = 90;       // fixed orientation (consistent in all views)
corner_sq_side = 0.010;  // square side length
corner_sq_rot_deg = 45;  // diamond orientation

// Corner hole offsets from edges
edge_margin_L = 0.015;
edge_margin_W = 0.015;

// Through-cut settings
tool_overlap = plate_T;                 // ensure cutters fully span plate
cut_through_H = plate_T + 2*tool_overlap;

// Helpers
function pent_points(r, rot_deg) =
    [ for (i = [0:4])
        [ r*cos(rot_deg + i*72), r*sin(rot_deg + i*72) ]
    ];

module plate_main_body() {
    cube([plate_L, plate_W, plate_T], center=true);
}

module center_pentagon_through_cutout() {
    // Keep the pentagon strictly in XY and extrude along Z for consistent orientation.
    linear_extrude(height=cut_through_H, center=true, convexity=10)
        polygon(points=pent_points(pent_R, pent_rot_deg));
}

module corner_hole(xsign, ysign) {
    translate([
        xsign*(plate_L/2 - edge_margin_L),
        ysign*(plate_W/2 - edge_margin_W),
        0
    ])
    rotate([0, 0, corner_sq_rot_deg])
        cube([corner_sq_side, corner_sq_side, cut_through_H], center=true);
}

difference() {
    plate_main_body();

    // Center pentagonal opening
    center_pentagon_through_cutout();

    // Four corner diamond holes
    corner_hole( 1,  1);
    corner_hole(-1,  1);
    corner_hole(-1, -1);
    corner_hole( 1, -1);
}
}
