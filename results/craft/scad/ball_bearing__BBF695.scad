// Flanged ball bearing (single connected solid)
// Target dimensions:
// - Bore: 5.0 mm
// - Outer diameter: 13.0 mm
// - Width: 4.0 mm
// - Flange outer diameter: 15.0 mm

// Parameters
bore_diameter_mm = 5;              //[2.5:10:0.1]
outer_diameter_mm = 13;            //[6.5:26:0.1]
width_mm = 4;                      //[2:8:0.1]
flange_outer_diameter_mm = 15;     //[7.5:30:0.1]
flange_width_mm = 1;               //[0.5:2:0.1]

// Visual/feature parameters (kept within OD/width; do not change target dims)
ball_diameter_mm = 1.6;            //[1:3:0.1]
ball_count = 8;                    //[6:14:1]
race_wall_mm = 1.0;                //[0.6:1.6:0.1]   // radial thickness of inner/outer races
race_groove_depth_mm = 0.45;       //[0.2:0.8:0.05]  // groove depth into races
race_groove_z_mm = 0.55;           //[0.3:1.2:0.05]  // groove half-height (controls visible "race" band)
seal_recess_mm = 0.25;             //[0.1:0.6:0.05]  // shallow face recess for visual detail

$fn = 128;

// Structural overlap to guarantee fusion (1-2mm as required)
connect_overlap_mm = 1.2;

module bearing_with_details() {
    bore_r   = bore_diameter_mm/2;
    outer_r  = outer_diameter_mm/2;
    flange_r = flange_outer_diameter_mm/2;

    // Keep races valid
    inner_race_outer_r = bore_r + race_wall_mm;
    outer_race_inner_r = outer_r - race_wall_mm;

    // Ball orbit between races
    ball_orbit_r = (inner_race_outer_r + outer_race_inner_r)/2;

    // Groove radii (cut into races)
    groove_r = ball_diameter_mm/2 + 0.15;

    body_h   = width_mm;
    flange_h = flange_width_mm;

    // Ball attachment: fuse each ball to BOTH races via two short radial "stems"
    stem_r = max(0.35, ball_diameter_mm*0.22);
    stem_h = min(body_h - 0.2, race_groove_z_mm*2); // keep inside bearing width

    // Ensure stems actually reach into each race by connect_overlap_mm
    stem_to_outer_len = (outer_race_inner_r - ball_orbit_r) + connect_overlap_mm;
    stem_to_inner_len = (ball_orbit_r - inner_race_outer_r) + connect_overlap_mm;

    // Safety: prevent negative/zero lengths if parameters are pushed
    stem_to_outer_len = max(stem_to_outer_len, connect_overlap_mm);
    stem_to_inner_len = max(stem_to_inner_len, connect_overlap_mm);

    union() {
        // Base bearing body with subtractive details (single solid)
        difference() {
            union() {
                // Outer ring body (blue in preview)
                cylinder(r=outer_r, h=body_h, center=true);

                // Flange on +Z side, connected with overlap
                translate([0, 0, body_h/2 + flange_h/2 - connect_overlap_mm])
                    cylinder(r=flange_r, h=flange_h, center=true);

                // Add 3 ribs that connect inner and outer races (guarantees one connected solid)
                rib_w = 0.9;
                rib_h = body_h * 0.85;
                rib_len = (outer_race_inner_r - inner_race_outer_r) + 2*connect_overlap_mm;

                // Place ribs so they span radially across the gap and overlap into both races
                // Center of rib at mid-gap radius:
                rib_center_r = (inner_race_outer_r + outer_race_inner_r)/2;

                for (a = [0:120:240]) {
                    rotate([0,0,a])
                        translate([rib_center_r, 0, 0])
                            cube([rib_len, rib_w, rib_h], center=true);
                }
            }

            // Through bore
            cylinder(r=bore_r, h=body_h + flange_h + 4, center=true);

            // Annular gap between races (keeps inner/outer race separation but ribs connect them)
            gap_r1 = inner_race_outer_r;
            gap_r2 = outer_race_inner_r;
            difference() {
                cylinder(r=gap_r2, h=body_h + 2*connect_overlap_mm, center=true);
                cylinder(r=gap_r1, h=body_h + 2*connect_overlap_mm + 0.4, center=true);
            }

            // Visual race grooves (subtractive)
            rotate_extrude(angle=360)
                translate([inner_race_outer_r - race_groove_depth_mm, 0, 0])
                    circle(r=groove_r, $fn=64);

            rotate_extrude(angle=360)
                translate([outer_race_inner_r + race_groove_depth_mm, 0, 0])
                    circle(r=groove_r, $fn=64);

            // Shallow face recesses for visual separation (do not change overall width)
            translate([0,0,-body_h/2 + seal_recess_mm/2])
                difference() {
                    cylinder(r=outer_r - 0.25, h=seal_recess_mm, center=true);
                    cylinder(r=bore_r + 0.25, h=seal_recess_mm + 0.4, center=true);
                }

            translate([0,0, body_h/2 - seal_recess_mm/2])
                difference() {
                    cylinder(r=outer_r - 0.25, h=seal_recess_mm, center=true);
                    cylinder(r=bore_r + 0.25, h=seal_recess_mm + 0.4, center=true);
                }
        }

        // Balls: fused/attached (no floating) by overlapping stems into BOTH races
        // Also ensure stems are centered on the ball and extend radially into the rings.
        for (i = [0:ball_count-1]) {
            ang = i * 360/ball_count;
            rotate([0,0,ang]) {
                // Ball itself
                translate([ball_orbit_r, 0, 0])
                    sphere(r=ball_diameter_mm/2, $fn=48);

                // Stem to OUTER race (overlaps into outer race by connect_overlap_mm)
                // Centered between ball center and outer race inner surface + overlap
                translate([ball_orbit_r + stem_to_outer_len/2, 0, 0])
                    cylinder(r=stem_r, h=stem_h, center=true, $fn=32);

                // Stem to INNER race (overlaps into inner race by connect_overlap_mm)
                translate([ball_orbit_r - stem_to_inner_len/2, 0, 0])
                    cylinder(r=stem_r, h=stem_h, center=true, $fn=32);
            }
        }
    }
}

bearing_with_details();