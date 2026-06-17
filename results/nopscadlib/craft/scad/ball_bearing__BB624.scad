// Ball bearing 4x13x5 (one connected solid) - FIXED CONNECTIVITY (no floating parts)
// Parameters
bore_diameter_mm  = 4.0;   //[2.0:8.0:0.1]
outer_diameter_mm = 13.0;  //[6.5:26.0:0.1]
width_mm          = 5.0;   //[2.5:10.0:0.1]

eps_mm = 0.05;             //[0.01:0.2:0.01]

// Visual/feature parameters (kept modest so dimensions remain correct)
outer_race_radial_mm = 1.25;   //[0.8:2.0:0.05]
inner_race_radial_mm = 1.05;   //[0.6:1.8:0.05]
race_groove_r_mm     = 0.55;   //[0.3:1.0:0.05]
ball_diameter_mm     = 1.6;    //[1.0:3.0:0.05]
num_balls            = 8;      //[5:14:1]

// Resolution
$fn = 128;

module torus(R, r) {
    rotate_extrude(convexity=10)
        translate([R, 0, 0])
            circle(r=r, $fn=64);
}

module bearing_4x13x5() {
    bore_r  = bore_diameter_mm/2;
    outer_r = outer_diameter_mm/2;
    w       = width_mm;

    // Clamp feature sizes so they always fit within the 4x13x5 envelope
    outer_race_rad = min(outer_race_radial_mm, (outer_r - bore_r)/2 - 0.6);
    inner_race_rad = min(inner_race_radial_mm, (outer_r - bore_r)/2 - 0.6);

    inner_race_od_r = bore_r + inner_race_rad;      // outer radius of inner ring
    outer_race_id_r = outer_r - outer_race_rad;     // inner radius of outer ring

    // Ball path radius between races
    ball_path_r = (inner_race_od_r + outer_race_id_r)/2;

    // Keep balls inside the bearing width
    ball_r = min(ball_diameter_mm/2, w/2 - 0.35);

    // Groove radius (visual), clamped to not break through rings
    groove_r = min(race_groove_r_mm,
                   (outer_race_rad - 0.25),
                   (inner_race_rad - 0.25),
                   (outer_race_id_r - inner_race_od_r)/2 - 0.15);

    // --- STRUCTURAL FIXES ---
    // 1) Ensure balls are physically attached (no clearance) by adding "cage bridges"
    //    that overlap inner ring, ball, and outer ring by 1-2mm.
    // 2) Ensure inner ring and outer ring are physically connected by adding a thin
    //    annular web (ring) that spans between them with 1-2mm overlap.
    overlap_mm = 1.2;                 // required 1-2mm overlap
    bridge_r   = max(0.40, ball_r*0.5);
    bridge_h   = min(w, 2*ball_r + 2*overlap_mm);

    // Bridge radial extents: extend into both rings (overlap)
    bridge_r_in  = inner_race_od_r - overlap_mm;
    bridge_r_out = outer_race_id_r + overlap_mm;

    // Annular web to connect inner and outer rings everywhere (guaranteed connectivity)
    web_thick_z = 1.6; // thickness along Z (kept modest)
    web_r_in    = inner_race_od_r - overlap_mm;
    web_r_out   = outer_race_id_r + overlap_mm;

    difference() {
        union() {
            // Outer ring with a shallow race groove
            difference() {
                cylinder(r=outer_r, h=w, center=true);
                cylinder(r=outer_race_id_r, h=w + 2*eps_mm, center=true);

                if (groove_r > 0)
                    torus(ball_path_r, groove_r);
            }

            // Inner ring with a shallow race groove
            difference() {
                cylinder(r=inner_race_od_r, h=w, center=true);
                // Slightly smaller than bore to avoid coincident surfaces with final bore cut
                cylinder(r=bore_r - eps_mm, h=w + 2*eps_mm, center=true);

                if (groove_r > 0)
                    torus(ball_path_r, groove_r);
            }

            // Annular web connecting inner and outer rings (no gap between rings)
            // (This is inside the bearing envelope and will be cut by the final bore only.)
            difference() {
                cylinder(r=web_r_out, h=web_thick_z, center=true);
                cylinder(r=web_r_in,  h=web_thick_z + 2*eps_mm, center=true);
            }

            // Balls + structural bridges (guaranteed overlap/merge)
            for (i = [0:num_balls-1]) {
                rotate([0, 0, i*360/num_balls]) {
                    // Ball (placed on the ball path)
                    translate([ball_path_r, 0, 0])
                        sphere(r=ball_r, $fn=64);

                    // Bridge: radial spoke intersecting inner ring, ball, and outer ring
                    // Recalculated translate so it spans [bridge_r_in .. bridge_r_out]
                    translate([(bridge_r_in + bridge_r_out)/2, 0, 0])
                        cube([bridge_r_out - bridge_r_in, 2*bridge_r, bridge_h], center=true);
                }
            }
        }

        // Final true circular bore (4.0mm)
        cylinder(r=bore_r, h=w + 2*eps_mm, center=true);
    }
}

bearing_4x13x5();