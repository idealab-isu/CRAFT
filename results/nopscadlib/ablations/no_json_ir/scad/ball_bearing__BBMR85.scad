$fn = 120;

// Ball bearing: 5.0mm bore, 8.0mm OD, 2.5mm width
// STRUCTURAL FIX: make the whole model ONE connected solid by adding
// small "bridges" (webs) that overlap 1–2mm between inner ring, outer ring,
// cage/race rings, and each ball.
module ball_bearing_5x8x2p5(
    bore_d = 5.0,
    od_d   = 8.0,
    width  = 2.5,
    ball_d = 0.8,
    nballs = 8,

    // Use 1–2mm overlap to guarantee fusion
    overlap = 1.2
){
    bore_r = bore_d/2;
    od_r   = od_d/2;

    ball_r = ball_d/2;
    ball_path_r = (bore_r + od_r)/2;

    // Keep balls within OD and outside bore (geometric sanity)
    assert(ball_path_r - ball_r > bore_r, "Balls intersect bore; reduce ball_d or adjust parameters.");
    assert(ball_path_r + ball_r < od_r,   "Balls exceed OD; reduce ball_d or adjust parameters.");

    // Ring thicknesses (kept close to original intent)
    // Outer ring occupies [outer_inner_r .. od_r]
    outer_inner_r = ball_path_r + ball_r - 0.2;
    // Inner ring occupies [bore_r .. inner_outer_r]
    inner_outer_r = ball_path_r - ball_r + 0.2;

    // Orange race/cage rings (thin concentric rings near the ball path)
    cage_th = 0.35;
    cage_r1 = ball_path_r - 0.55;
    cage_r2 = ball_path_r + 0.55;

    // Bridge geometry: small radial webs that physically connect everything.
    // These are intentionally small so the bearing still "looks" like a bearing,
    // but becomes one watertight solid.
    web_w = max(0.6, ball_d*0.55);     // tangential width of each web
    web_h = width;                     // full width so it fuses through Z
    // Ensure the web spans from inner ring to outer ring with overlap on both ends
    web_len = (outer_inner_r - inner_outer_r) + 2*overlap;

    // Ball-to-ring "stems": tiny cylinders that intersect the ball and the rings
    // so balls are not separate bodies.
    stem_r = max(0.25, ball_r*0.45);
    stem_h = width + 2*overlap;

    union() {

        // OUTER RING (blue)
        difference() {
            cylinder(h=width, r=od_r, center=true);
            cylinder(h=width + 2*overlap, r=outer_inner_r, center=true);
        }

        // INNER RING (blue)
        difference() {
            cylinder(h=width, r=inner_outer_r, center=true);
            cylinder(h=width + 2*overlap, r=bore_r, center=true);
        }

        // ORANGE RACE/CAGE ELEMENTS (now physically attached via webs)
        // Two thin rings around the ball path.
        for (cr = [cage_r1, cage_r2]) {
            difference() {
                cylinder(h=width, r=cr + cage_th/2, center=true);
                cylinder(h=width + 2*overlap, r=cr - cage_th/2, center=true);
            }
        }

        // BALLS + STEMS (stems ensure each ball is fused to the rest)
        for (i = [0:nballs-1]) {
            ang = i*360/nballs;

            // Ball
            rotate([0,0,ang])
                translate([ball_path_r, 0, 0])
                    sphere(r=ball_r);

            // Two small stems per ball (inward and outward) to guarantee fusion
            // with inner/outer ring material (and they also intersect the cage rings).
            rotate([0,0,ang]) {
                // inward stem (toward inner ring)
                translate([ball_path_r - (ball_r + overlap*0.6), 0, 0])
                    cylinder(h=stem_h, r=stem_r, center=true);

                // outward stem (toward outer ring)
                translate([ball_path_r + (ball_r + overlap*0.6), 0, 0])
                    cylinder(h=stem_h, r=stem_r, center=true);
            }
        }

        // RADIAL WEBS (primary structural fix):
        // These connect inner ring <-> cage rings <-> outer ring as one solid.
        // Positioned at the same angles as balls so they are visually consistent.
        for (i = [0:nballs-1]) {
            ang = i*360/nballs;

            rotate([0,0,ang])
                translate([(inner_outer_r + outer_inner_r)/2, 0, 0])
                    cube([web_len, web_w, web_h], center=true);
        }
    }
}

ball_bearing_5x8x2p5();