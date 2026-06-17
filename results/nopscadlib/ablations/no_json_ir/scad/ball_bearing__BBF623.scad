$fn = 160;

// Flanged ball bearing (single connected solid)
// Specs: bore=3.0mm, OD=10.0mm, width=4.0mm, flange OD=11.5mm
module flanged_ball_bearing(
    bore_d   = 3.0,
    od_d     = 10.0,
    width    = 4.0,
    flange_d = 11.5,
    flange_t = 0.6,     // flange thickness (part of total width)
    // Visual bearing details (kept subtle so OD/width remain exact)
    ball_d     = 1.0,
    ball_count = 8,
    clearance  = 0.12,
    overlap    = 0.05
) {
    r_bore   = bore_d/2;
    r_outer  = od_d/2;
    r_flange = flange_d/2;

    body_h = width - flange_t;

    // Z layout: bottom at 0, top at width
    z_body0   = 0;
    z_body1   = body_h;
    z_flange0 = body_h - overlap;
    z_flange1 = width;

    // Ball path radius between bore and OD
    r_ball_path = (r_bore + r_outer)/2;

    // Keep enough material for inner/outer rings
    ring_min = 0.55; // minimum wall thickness for visual solidity
    r_inner_ring_od = min(r_outer - ring_min, r_bore + (r_outer - r_bore)*0.55);
    r_outer_ring_id = max(r_inner_ring_od + ring_min, r_outer - (r_outer - r_bore)*0.45);

    // Race groove size (visual)
    groove_r = ball_d/2 + clearance;
    groove_z = body_h/2;

    // Small "cage" web to ensure balls are part of ONE connected solid
    cage_t = 0.35;
    cage_r1 = r_ball_path - ball_d*0.35;
    cage_r2 = r_ball_path + ball_d*0.35;

    difference() {
        // SOLID: outer ring + inner ring + flange + balls + cage web (all connected)
        union() {
            // Outer ring (exact OD)
            cylinder(r=r_outer, h=body_h);

            // Inner ring (around bore) to make it look like a bearing, not a bushing
            // Connected to outer ring via the cage web and balls.
            cylinder(r=r_inner_ring_od, h=body_h);

            // Flange (exact flange OD), connected with overlap
            translate([0,0,z_flange0])
                cylinder(r=r_flange, h=flange_t + overlap);

            // Cage web (thin annulus) to connect inner/outer rings and balls
            translate([0,0,groove_z - cage_t/2])
                difference() {
                    cylinder(r=cage_r2, h=cage_t);
                    cylinder(r=cage_r1, h=cage_t + 2*overlap);
                }

            // Balls (slightly embedded so they union with cage/rings)
            for (i = [0:ball_count-1]) {
                rotate([0,0,i*360/ball_count])
                    translate([r_ball_path, 0, groove_z])
                        sphere(d=ball_d);
            }
        }

        // Bore through entire width (exact bore)
        translate([0,0,-overlap])
            cylinder(r=r_bore, h=width + 2*overlap);

        // Remove the annular space between inner and outer rings (bearing cavity)
        // This creates visible separation between races while keeping one connected solid
        // due to the cage web + balls.
        translate([0,0,-overlap])
            difference() {
                cylinder(r=r_outer_ring_id, h=body_h + 2*overlap);
                cylinder(r=r_inner_ring_od, h=body_h + 2*overlap);
            }

        // Race grooves (visual detail) carved into the rings
        // Outer race groove
        translate([0,0,groove_z])
            rotate_extrude()
                translate([r_ball_path, 0, 0])
                    circle(r=groove_r);

        // Inner race groove (slightly smaller)
        translate([0,0,groove_z])
            rotate_extrude()
                translate([r_ball_path, 0, 0])
                    circle(r=groove_r*0.92);
    }
}

flanged_ball_bearing();