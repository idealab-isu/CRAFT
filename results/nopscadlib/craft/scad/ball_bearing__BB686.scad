// Ball bearing (single connected solid)
// Bore: 6.0mm, OD: 13.0mm, Width: 5.0mm

$fn = 180;

bore_d = 6.0;
od_d   = 13.0;
w      = 5.0;

eps = 0.02;

// Detail parameters (kept within envelope)
ball_d     = 1.6;
ball_count = 8;

// Visual groove depth (does not change OD/ID envelope)
groove_depth = 0.35;

// Cage parameters (keeps everything one connected solid)
cage_th        = 0.70;  // axial thickness of cage ring
cage_rad_th    = 0.55;  // radial thickness around balls
bridge_w       = 0.55;  // tangential width of bridges
bridge_overlap = 0.25;  // overlap into ball and cage to guarantee connectivity

module bearing() {
    r_bore = bore_d/2;
    r_od   = od_d/2;

    // Ball center radius (between bore and OD, leaving room for ball radius + grooves)
    // Use a formula and clamp to stay safely inside the envelope.
    r_ball_nom = (r_bore + r_od)/2;
    r_ball_min = r_bore + (ball_d/2 + groove_depth + 0.35);
    r_ball_max = r_od   - (ball_d/2 + groove_depth + 0.35);
    r_ball = min(max(r_ball_nom, r_ball_min), r_ball_max);

    // Cage ring radii around the balls (clamped to stay within OD/ID)
    r_cage_in_nom  = r_ball - ball_d/2 - cage_rad_th;
    r_cage_out_nom = r_ball + ball_d/2 + cage_rad_th;

    r_cage_in  = max(r_cage_in_nom,  r_bore + 0.35);
    r_cage_out = min(r_cage_out_nom, r_od   - 0.35);

    // Raceway groove profile radius (visual)
    groove_r = ball_d/2 + groove_depth;

    union() {
        // Outer envelope with bore and raceway grooves
        difference() {
            cylinder(h=w, r=r_od, center=true);

            // Bore
            cylinder(h=w + 2*eps, r=r_bore, center=true);

            // Raceway groove (torus-like cut) centered at r_ball
            // Use h=w+2*eps so the groove actually cuts through the body.
            rotate_extrude($fn=180)
                translate([r_ball, 0, 0])
                    circle(r=groove_r, $fn=96);
        }

        // Cage + balls (connected to each other; also overlaps into main body via bridges)
        union() {
            // Cage ring
            difference() {
                cylinder(h=cage_th, r=r_cage_out, center=true);
                cylinder(h=cage_th + 2*eps, r=r_cage_in, center=true);
            }

            // Balls + bridges
            for (i = [0:ball_count-1]) {
                ang = i * 360 / ball_count;

                // Ball
                rotate([0,0,ang])
                    translate([r_ball, 0, 0])
                        sphere(r=ball_d/2, $fn=96);

                // Bridge: tangential bar that overlaps into ball and cage ring
                // Also overlaps slightly into the main body (since cage sits inside the annulus).
                rotate([0,0,ang])
                    translate([r_ball, 0, 0])
                        cube([ball_d + 2*bridge_overlap, bridge_w, cage_th], center=true);
            }
        }
    }
}

bearing();