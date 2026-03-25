// Dimension-calibrated (target: 0.18 x 0.13 x 0.01 mm)
scale([0.920085, 1.330325, 1.000168])
{
// Thin plate with rounded outer corners + 4 rotated polygon cutouts (through-holes)
// Units: mm

$fn = 64;

// Parameters (match ~0.2 x 0.1 x thin)
plate_L = 0.20;
plate_W = 0.10;
plate_T = 0.01;

corner_R = 0.008;          // outer corner radius
cutout_sides = 6;          // polygonal opening (hex-like)
cutout_flat_d = 0.012;     // across-flats size
cutout_angle_deg = 30;     // rotate cutouts relative to edges
cutout_edge_offset_x = 0.018;
cutout_edge_offset_y = 0.016;

overlap = 0.002;

// Rounded rectangle plate (true rounded outer corners)
module rounded_plate(L, W, T, R) {
    // Ensure valid radius
    r = min(R, min(L, W)/2 - 1e-6);

    linear_extrude(height=T, center=true)
        offset(r=r)
            square([L - 2*r, W - 2*r], center=true);
}

// Regular polygon cutout sized by across-flats (for even/odd n)
module poly_cutout(n, flat_d, h) {
    // For a regular n-gon: apothem a = R*cos(pi/n); across-flats = 2a
    // => circumradius R = (flat_d/2)/cos(pi/n)
    R = (flat_d/2) / cos(180/n);

    linear_extrude(height=h, center=true)
        circle(r=R, $fn=n);
}

module corner_cutouts() {
    for (sx = [-1, 1], sy = [-1, 1]) {
        translate([sx*(plate_L/2 - cutout_edge_offset_x),
                   sy*(plate_W/2 - cutout_edge_offset_y),
                   0])
            rotate([0, 0, cutout_angle_deg])
                poly_cutout(cutout_sides, cutout_flat_d, plate_T + 2*overlap);
    }
}

difference() {
    rounded_plate(plate_L, plate_W, plate_T, corner_R);
    corner_cutouts();
}
}
