$fn = 180;

// Target bearing dimensions (mm)
bore_diameter  = 40.0;  // ID
outer_diameter = 52.0;  // OD
width          = 7.0;   // W

// Visual/detail parameters
num_balls      = 12;
ball_diameter  = 3.0;
seal_thickness = 0.6;
overlap        = 0.20;  // ensure manifold unions

module ball_bearing() {
    id = bore_diameter;
    od = outer_diameter;
    w  = width;

    id_r = id/2;
    od_r = od/2;

    ball_r = ball_diameter/2;

    // Radial space available between ID and OD
    radial_gap = od_r - id_r;

    // Keep some steel around the balls
    min_wall = 1.0;

    // Clamp ball size if needed (still uses given ball_diameter when it fits)
    ball_r_eff = min(ball_r, (radial_gap/2) - min_wall);
    ball_d_eff = 2*ball_r_eff;

    // Ball path radius centered in the annulus, clamped to keep walls
    ball_path_r_nom = (id_r + od_r)/2;
    ball_path_r = min(
        max(ball_path_r_nom, id_r + min_wall + ball_r_eff),
        od_r - min_wall - ball_r_eff
    );

    // Raceway groove radius (slightly larger than ball radius)
    groove_r = ball_r_eff * 1.10;

    // Place grooves near each face so they are visible in side view
    groove_z = w*0.28;

    // Cage ring: thin ring around ball path, connected to balls via overlap
    cage_th = 0.9;
    cage_h  = w*0.55;

    // Shields: thin discs, slightly overlapped into body
    seal_th = seal_thickness;

    union() {
        // Outer ring with bore and raceway grooves (bearing body)
        difference() {
            cylinder(d=od, h=w, center=true);

            // Through bore (make it unmistakably visible)
            cylinder(d=id, h=w + 2, center=true);

            // Raceway grooves (torus-like cuts) on both sides
            for (zsign = [-1, 1]) {
                translate([0, 0, zsign*groove_z])
                    rotate_extrude(angle=360, $fn=180)
                        translate([ball_path_r, 0, 0])
                            circle(r=groove_r, $fn=96);
            }

            // Center relief to visually separate inner/outer races without removing the whole ring
            // Keep a web so the body remains one piece.
            relief_d = id + (od - id)*0.55;
            relief_h = w*0.40;
            cylinder(d=relief_d, h=relief_h, center=true);
        }

        // Balls (slightly enlarged for guaranteed contact with cage/body)
        for (i = [0:num_balls-1]) {
            ang = i * 360/num_balls;
            rotate([0, 0, ang])
                translate([ball_path_r, 0, 0])
                    sphere(r=ball_r_eff + overlap, $fn=64);
        }

        // Cage ring (connected to balls via overlap)
        difference() {
            cylinder(r=ball_path_r + cage_th/2, h=cage_h, center=true);
            cylinder(r=ball_path_r - cage_th/2, h=cage_h + 2, center=true);
        }

        // Thin shields (overlap into body so they connect)
        for (zsign = [-1, 1]) {
            translate([0, 0, zsign*(w/2 - seal_th/2 - overlap)])
                difference() {
                    cylinder(d=od, h=seal_th, center=true);
                    // Leave a visible opening larger than bore to suggest shielded bearing
                    cylinder(d=id + 2.0, h=seal_th + 2, center=true);
                }
        }
    }
}

ball_bearing();