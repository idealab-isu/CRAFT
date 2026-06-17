$fn = 140;

module ball_bearing_5x9x2_5() {
    // Target dimensions (verified by construction)
    bore_d = 5.0;
    od_d   = 9.0;
    w      = 2.5;

    // Small overlap/clearance helpers
    eps = 0.02;
    ov  = 0.06;   // overlap to guarantee connectivity

    r_bore = bore_d/2;
    r_od   = od_d/2;

    // Visual bearing details (kept within OD/width)
    nballs = 8;
    ball_d = 1.05;

    // Ball center radius: keep balls between bore and OD with margin
    margin = 0.25;
    r_path = (r_bore + ball_d/2 + margin + r_od - ball_d/2 - margin) / 2;

    // Inner race (ring) dimensions (kept outside bore)
    inner_race_id = bore_d + 0.60;                 // > bore
    inner_race_od = min(od_d - 1.60, r_path*2 - 0.20);

    // Outer race (ring) dimensions (kept inside OD)
    outer_race_id = max(inner_race_od + 0.35, r_path*2 + 0.20);
    outer_race_od = od_d;

    // Cage (simple ring with pockets)
    cage_t = 0.55;
    cage_id = max(inner_race_od + 0.10, r_path*2 - ball_d*0.75);
    cage_od = min(outer_race_id - 0.10, r_path*2 + ball_d*0.75);

    // Raceway grooves (visual)
    groove_r = ball_d * 0.55;

    // Shields (visual, fused)
    shield_t = 0.22;
    shield_inset = 0.18;
    shield_d = od_d - 2*shield_inset;

    // Z placement for shields: inside width, with slight overlap into races
    shield_z = (w/2 - shield_t/2) - 0.02;

    // Chamfer sizes (visual)
    cham_h = 0.22;
    cham_d = 0.45;

    difference() {
        // ONE connected solid: inner race + outer race + cage + balls + shields
        union() {
            // Outer race ring
            difference() {
                cylinder(d=outer_race_od, h=w, center=true);
                cylinder(d=outer_race_id, h=w + 2*eps, center=true);
            }

            // Inner race ring (fused to balls/cage via overlaps)
            difference() {
                cylinder(d=inner_race_od, h=w, center=true);
                cylinder(d=inner_race_id, h=w + 2*eps, center=true);
            }

            // Cage ring (thin) with ball pockets removed later (in outer difference)
            difference() {
                cylinder(d=cage_od, h=w - 2*shield_t + 2*ov, center=true);
                cylinder(d=cage_id, h=w - 2*shield_t + 2*ov + 2*eps, center=true);
            }

            // Balls (slightly oversized for guaranteed fusion)
            for (i = [0:nballs-1]) {
                rotate([0, 0, i*360/nballs])
                    translate([r_path, 0, 0])
                        sphere(d=ball_d + ov);
            }

            // Shields (thin discs, slightly overlapping into races so they are connected)
            for (zsgn = [-1, 1]) {
                translate([0, 0, zsgn*shield_z])
                    cylinder(d=shield_d, h=shield_t + ov, center=true);
            }
        }

        // Through bore (exact 5.0mm)
        cylinder(d=bore_d, h=w + 2*eps, center=true);

        // Raceway grooves (visual) centered on ball path, cut from both races
        // Use two grooves (one near each face) to make bearing look less like a plain ring
        groove_z = (w/2 - shield_t - groove_r - 0.10);
        for (zsgn = [-1, 1]) {
            translate([0, 0, zsgn*groove_z])
                rotate_extrude()
                    translate([r_path, 0, 0])
                        circle(r=groove_r);
        }

        // Cage ball pockets (cutouts) to show separation between balls
        // Pockets are slightly larger than balls and only through the cage thickness region
        pocket_h = w - 2*shield_t + 0.30;
        for (i = [0:nballs-1]) {
            rotate([0, 0, i*360/nballs])
                translate([r_path, 0, 0])
                    cylinder(d=ball_d*1.18, h=pocket_h, center=true);
        }

        // OD chamfers (visual)
        for (zsgn = [-1, 1]) {
            translate([0, 0, zsgn*(w/2 - cham_h/2)])
                cylinder(d1=od_d, d2=od_d - cham_d, h=cham_h + eps, center=true);
        }

        // Bore chamfers (visual) - do not change bore at mid-plane, only edge relief
        for (zsgn = [-1, 1]) {
            translate([0, 0, zsgn*(w/2 - cham_h/2)])
                cylinder(d1=bore_d + cham_d, d2=bore_d, h=cham_h + eps, center=true);
        }
    }
}

ball_bearing_5x9x2_5();