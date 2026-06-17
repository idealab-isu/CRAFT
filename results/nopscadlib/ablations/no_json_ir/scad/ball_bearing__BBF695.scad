$fn = 160;

module flanged_radial_ball_bearing(
    bore_d   = 5.0,
    od_d     = 13.0,
    width_h  = 4.0,
    flange_d = 15.0,
    flange_h = 1.0,
    lip_h    = 0.6,   // small step to suggest race detail
    lip_d    = 11.2   // inner step diameter (visual detail)
) {
    eps = 0.02;

    // One connected solid: outer body (with flange + race step) minus through-bore
    difference() {
        union() {
            // Main outer ring (OD 13, full width)
            cylinder(d = od_d, h = width_h, center = false);

            // Flange on one face (OD 15, thickness flange_h), connected at z=0
            cylinder(d = flange_d, h = flange_h, center = false);

            // Small race step on the opposite face to show bearing detail
            translate([0, 0, width_h - lip_h])
                cylinder(d = lip_d, h = lip_h, center = false);
        }

        // Through bore (5mm) cut all the way through with slight overcut
        translate([0, 0, -eps])
            cylinder(d = bore_d, h = width_h + 2*eps, center = false);
    }
}

flanged_radial_ball_bearing();