// Ball bearing 6x13x5 (bore x OD x width) with visible balls/raceways/cage
// One connected solid (balls/cage fused to races via tiny bridges)

$fn = 160;

// Requested dimensions
bore_diameter_mm  = 6.0;
outer_diameter_mm = 13.0;
width_mm          = 5.0;

// Detail parameters (kept formula-based, no arbitrary placement)
ball_diameter_mm = 2.0;
ball_count       = 8;

// Small overlaps/bridges to guarantee a single connected manifold
eps_mm        = 0.02;
bridge_mm     = 0.18;   // tiny connector thickness to fuse balls/cage to races
overlap_z_mm  = 0.10;   // z overlap for unions

module ball_bearing_6x13x5() {
    // Radii
    r_bore  = bore_diameter_mm/2;
    r_outer = outer_diameter_mm/2;

    // Ball/race geometry
    r_ball  = ball_diameter_mm/2;

    // Choose a realistic pitch radius that fits between bore and OD
    // Ensure clearance to both sides:
    // r_pitch - r_ball > r_bore
    // r_pitch + r_ball < r_outer
    r_pitch = (r_bore + r_outer)/2;

    // Race thicknesses (radial)
    // Keep enough material outside/inside the ball groove
    outer_wall = max(0.9, (r_outer - (r_pitch + r_ball)) + 0.9);
    inner_wall = max(0.9, ((r_pitch - r_ball) - r_bore) + 0.9);

    // Convert to actual race radii
    r_outer_inner = r_outer - outer_wall; // inner radius of outer race
    r_inner_outer = r_bore + inner_wall;  // outer radius of inner race

    // Groove depth (radial) and z position
    groove_depth = r_ball * 0.55; // visible raceway without weakening too much
    z_groove     = 0;

    // Cage (simple ring) around balls
    cage_th      = 0.7;
    cage_r_in    = r_pitch - r_ball*0.85;
    cage_r_out   = r_pitch + r_ball*0.85;

    // Ensure cage stays within bearing envelope
    cage_r_in  = max(cage_r_in,  r_inner_outer + 0.15);
    cage_r_out = min(cage_r_out, r_outer_inner - 0.15);

    // Ball pocket radius in cage
    pocket_r = r_ball * 0.92;

    union() {
        // OUTER RACE with groove
        difference() {
            cylinder(r=r_outer, h=width_mm, center=true);
            // Hollow to inner radius
            cylinder(r=r_outer_inner, h=width_mm + 2*eps_mm, center=true);

            // Raceway groove (torus-like via rotate_extrude)
            rotate_extrude(convexity=10)
                translate([r_pitch, 0, 0])
                    circle(r=groove_depth, $fn=96);
        }

        // INNER RACE with groove
        difference() {
            cylinder(r=r_inner_outer, h=width_mm, center=true);
            // Bore
            cylinder(r=r_bore, h=width_mm + 2*eps_mm, center=true);

            // Raceway groove
            rotate_extrude(convexity=10)
                translate([r_pitch, 0, 0])
                    circle(r=groove_depth, $fn=96);
        }

        // CAGE ring with ball pockets (kept inside races)
        difference() {
            cylinder(r=cage_r_out, h=cage_th, center=true);
            cylinder(r=cage_r_in,  h=cage_th + 2*eps_mm, center=true);

            // Pockets
            for (i = [0:ball_count-1]) {
                rotate([0, 0, i*360/ball_count])
                    translate([r_pitch, 0, 0])
                        cylinder(r=pocket_r, h=cage_th + 2*eps_mm, center=true, $fn=64);
            }
        }

        // BALLS (fused to cage/races with tiny bridges so model is one connected solid)
        for (i = [0:ball_count-1]) {
            rotate([0, 0, i*360/ball_count]) {
                // Ball
                translate([r_pitch, 0, z_groove])
                    sphere(r=r_ball, $fn=96);

                // Bridge from ball to cage (radial small block overlapping both)
                // Positioned so it intersects the ball and the cage ring.
                translate([r_pitch, 0, 0])
                    rotate([0, 90, 0])
                        cylinder(r=bridge_mm/2, h=(cage_th/2 + r_ball) + overlap_z_mm, center=true, $fn=24);

                // Bridge from ball to inner race (tiny radial tab inward)
                translate([r_pitch - r_ball*0.65, 0, 0])
                    cube([bridge_mm, bridge_mm, width_mm*0.35], center=true);

                // Bridge from ball to outer race (tiny radial tab outward)
                translate([r_pitch + r_ball*0.65, 0, 0])
                    cube([bridge_mm, bridge_mm, width_mm*0.35], center=true);
            }
        }
    }
}

ball_bearing_6x13x5();