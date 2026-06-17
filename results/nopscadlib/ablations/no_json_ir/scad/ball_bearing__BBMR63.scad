$fn = 160;

// Ball bearing: 3.0mm bore, 6.0mm OD, 2.5mm width
// One connected solid with visible bore, race grooves, balls, and cage.

module ball_bearing(
    bore_d = 3.0,
    od_d   = 6.0,
    width  = 2.5,
    ball_d = 0.75,
    nballs = 8
) {
    eps = 0.02;

    r_bore = bore_d/2;
    r_od   = od_d/2;

    // Keep some material around bore and OD
    min_wall = 0.35;

    // Ball path radius centered between bore and OD, but keep walls
    r_path = (r_bore + min_wall) + ( (r_od - min_wall) - (r_bore + min_wall) )/2;

    // Clamp ball size to fit radially and axially
    ring_radial = r_od - r_bore;
    ball_r_max_rad = max(0.01, ring_radial/2 - min_wall);
    ball_r_max_ax  = max(0.01, width/2 - min_wall);
    ball_r = min(ball_d/2, ball_r_max_rad, ball_r_max_ax);
    ball_d_eff = 2*ball_r;

    // Groove radius slightly larger than ball for visible race detail
    groove_r = ball_r * 1.10;

    // Cage thickness and radial bounds around the ball path
    cage_t = max(0.35, ball_r * 0.60);
    cage_r_in  = max(r_bore + min_wall, r_path - ball_r - cage_t/2);
    cage_r_out = min(r_od   - min_wall, r_path + ball_r + cage_t/2);

    // Small overlap to guarantee single connected solid (balls fuse to races/cage)
    fuse = max(0.03, ball_r * 0.08);

    union() {
        // Races with grooves and through bore
        difference() {
            cylinder(h=width, d=od_d, center=true);

            // Through bore (ensure it cuts fully)
            cylinder(h=width + 2*eps, d=bore_d, center=true);

            // Main race groove (torus-like cut)
            rotate_extrude(convexity=10)
                translate([r_path, 0, 0])
                    circle(r=groove_r);

            // Slightly offset secondary cuts to hint inner/outer race shoulders
            translate([0, 0,  width*0.18])
                rotate_extrude(convexity=10)
                    translate([r_path, 0, 0])
                        circle(r=groove_r*0.90);

            translate([0, 0, -width*0.18])
                rotate_extrude(convexity=10)
                    translate([r_path, 0, 0])
                        circle(r=groove_r*0.90);
        }

        // Balls (slightly enlarged to ensure fusion with races/cage)
        for (i = [0:nballs-1]) {
            rotate([0, 0, i*360/nballs])
                translate([r_path, 0, 0])
                    sphere(r=ball_r + fuse);
        }

        // Cage ring with pockets (kept within envelope), fused to balls/races
        difference() {
            cylinder(h=cage_t, r=cage_r_out, center=true);
            cylinder(h=cage_t + 2*eps, r=cage_r_in, center=true);

            for (i = [0:nballs-1]) {
                rotate([0, 0, i*360/nballs])
                    translate([r_path, 0, 0])
                        cylinder(h=cage_t + 2*eps, d=ball_d_eff*1.18, center=true);
            }
        }
    }
}

ball_bearing();