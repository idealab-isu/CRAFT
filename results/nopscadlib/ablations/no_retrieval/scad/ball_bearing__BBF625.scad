// Flanged ball bearing (single connected solid)
// Target: 5.0mm bore, 16.0mm OD, 5.0mm width, 18.0mm flange OD

$fn = 160;

// Parameters
bore_d        = 5.0;   //[2.5:10.0:0.1]
od_d          = 16.0;  //[8.0:32.0:0.1]
width         = 5.0;   //[2.5:10.0:0.1]
flange_od_d   = 18.0;  //[9.0:36.0:0.1]
flange_thk    = 1.0;   //[0.5:2.0:0.05]

// Visual/detail parameters (kept subtle but visible)
inner_ring_od_d   = 9.0;   //[4.5:18.0:0.1]
outer_ring_id_d   = 12.0;  //[6.0:24.0:0.1]
groove_depth      = 0.45;  //[0.2:0.9:0.05]
groove_width      = 1.2;   //[0.6:2.4:0.05]
shield_thk        = 0.25;  //[0.1:0.6:0.05]
ball_d            = 2.0;   //[1.0:4.0:0.05]
ball_count        = 8;     //[6:14:1]
cage_thk          = 0.8;   //[0.4:1.6:0.05]
cage_radial_thk   = 0.6;   //[0.3:1.2:0.05]

// Robust boolean overlap
overlap = 0.6; //[0.2:2.0:0.1]

// Derived
ball_path_r = (outer_ring_id_d/2 + inner_ring_od_d/2)/2;

// Safety checks (geometry sanity)
assert(bore_d < inner_ring_od_d, "bore_d must be smaller than inner_ring_od_d");
assert(inner_ring_od_d < outer_ring_id_d, "inner_ring_od_d must be smaller than outer_ring_id_d");
assert(outer_ring_id_d < od_d, "outer_ring_id_d must be smaller than od_d");
assert(flange_od_d >= od_d, "flange_od_d should be >= od_d");
assert(flange_thk <= width, "flange_thk must be <= width");

// -------------------- Base solids --------------------
module outer_ring_solid() {
    cylinder(h=width, r=od_d/2, center=true);
}

module flange_solid() {
    // Flange on +Z face, connected with slight overlap
    translate([0,0, width/2 - flange_thk/2 - overlap/2])
        cylinder(h=flange_thk + overlap, r=flange_od_d/2, center=true);
}

module inner_ring_solid() {
    cylinder(h=width, r=inner_ring_od_d/2, center=true);
}

// -------------------- Cuts / details --------------------
module bore_cut() {
    cylinder(h=width + 4*overlap, r=bore_d/2, center=true);
}

module outer_ring_id_cut() {
    cylinder(h=width + 4*overlap, r=outer_ring_id_d/2, center=true);
}

// Race grooves (torus-like cuts limited to bearing width)
module groove_window(z_center=0) {
    translate([0,0,z_center])
        cube([od_d + 4*overlap, od_d + 4*overlap, groove_width], center=true);
}

module outer_race_groove_cut() {
    // Cut a circular groove near the inner diameter of the outer ring
    intersection() {
        rotate_extrude()
            translate([outer_ring_id_d/2 + groove_depth, 0, 0])
                circle(r=groove_width/2);
        groove_window(0);
    }
}

module inner_race_groove_cut() {
    // Cut a circular groove near the outer diameter of the inner ring
    intersection() {
        rotate_extrude()
            translate([inner_ring_od_d/2 - groove_depth, 0, 0])
                circle(r=groove_width/2);
        groove_window(0);
    }
}

// Shields (thin rings) - kept connected via tiny overlap into outer ring
module shield(zsign=1) {
    z = zsign*(width/2 - shield_thk/2);
    translate([0,0,z])
        difference() {
            cylinder(h=shield_thk + overlap, r=outer_ring_id_d/2 - 0.15, center=true);
            cylinder(h=shield_thk + 3*overlap, r=inner_ring_od_d/2 + 0.15, center=true);
        }
}

// Cage ring (simple ring around balls) - connected by slight overlap to shields/balls
module cage_ring() {
    difference() {
        cylinder(h=cage_thk + overlap, r=ball_path_r + ball_d/2 + cage_radial_thk, center=true);
        cylinder(h=cage_thk + 3*overlap, r=ball_path_r - ball_d/2 - cage_radial_thk, center=true);
    }
}

// Balls (for visual detail). They will be fused into the single solid.
module balls() {
    for (i = [0:ball_count-1]) {
        rotate([0,0,i*360/ball_count])
            translate([ball_path_r, 0, 0])
                sphere(r=ball_d/2);
    }
}

// -------------------- Final assembly (ONE connected solid) --------------------
module bearing() {
    // Make a single connected solid with a real through-bore.
    difference() {
        union() {
            // Outer ring with flange
            difference() {
                union() {
                    outer_ring_solid();
                    flange_solid();
                }
                // Outer ring inner diameter
                outer_ring_id_cut();
                // Outer race groove
                outer_race_groove_cut();
            }

            // Inner ring (kept as solid ring; bore cut applied at end)
            difference() {
                inner_ring_solid();
                // Inner race groove
                inner_race_groove_cut();
            }

            // Shields + cage + balls (all fused)
            shield( 1);
            shield(-1);
            cage_ring();
            balls();
        }

        // Final through-bore cut ensures visible 5mm hole through everything
        bore_cut();
    }
}

bearing();