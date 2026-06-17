$fn = 160;

// Ball bearing: 4.0mm bore, 13.0mm OD, 5.0mm width
bore_d  = 4.0;
od_d    = 13.0;
width   = 5.0;

eps = 0.02; // small overlap to ensure watertight unions/differences

module ball_bearing_4x13x5() {

    // --- Envelope constraints (must remain exact) ---
    // OD = od_d, bore = bore_d, width = width

    // --- Internal geometry (kept within envelope) ---
    // Choose race diameters so rings have reasonable thickness and leave room for balls.
    inner_ring_od = 7.2;     // outer diameter of inner ring (must be > bore_d)
    outer_ring_id = 10.6;    // inner diameter of outer ring (must be < od_d)

    // Balls
    ball_d  = 1.6;
    n_balls = 8;

    // Ball center radius: centered between raceway diameters
    ball_r = (inner_ring_od/2 + outer_ring_id/2) / 2;

    // Cage: a thin ring that touches balls and overlaps rings slightly to ensure ONE connected solid
    cage_h      = width * 0.55;
    cage_od     = 2*(ball_r + ball_d/2);
    cage_id     = 2*(ball_r - ball_d/2);

    // Small radial overlap so cage fuses to both rings (not just to balls)
    fuse_r = 0.12;
    cage_od_fused = min(outer_ring_id + 2*fuse_r, od_d - 2*eps);
    cage_id_fused = max(inner_ring_od - 2*fuse_r, bore_d + 2*eps);

    union() {
        // Outer ring (exact OD and width)
        difference() {
            cylinder(d=od_d, h=width, center=true);
            cylinder(d=outer_ring_id, h=width + 2*eps, center=true);
        }

        // Inner ring (exact bore and width)
        difference() {
            cylinder(d=inner_ring_od, h=width, center=true);
            cylinder(d=bore_d, h=width + 2*eps, center=true);
        }

        // Cage (touches balls; slightly overlaps rings to guarantee connectivity)
        difference() {
            cylinder(d=cage_od_fused, h=cage_h, center=true);
            cylinder(d=cage_id_fused, h=cage_h + 2*eps, center=true);
        }

        // Balls (sit between rings; intersect cage slightly for robust union)
        for (i = [0 : n_balls-1]) {
            rotate([0, 0, i * 360/n_balls])
                translate([ball_r, 0, 0])
                    sphere(d=ball_d);
        }
    }
}

ball_bearing_4x13x5();