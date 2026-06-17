$fn = 180;

bore_d = 6.0;
od_d   = 13.0;
width  = 5.0;

// Simple ball bearing representation: outer ring + inner ring + ball cage with balls
// Dimensions are nominal; internal geometry is illustrative.

module bearing_6x13x5() {
    outer_r = od_d/2;
    inner_r = bore_d/2;

    // Ring thicknesses (illustrative, kept reasonable for this size)
    ring_radial = 1.2;   // radial thickness of each ring
    ring_axial  = 0.9;   // axial thickness of each ring (each side)

    // Derived radii
    outer_ring_inner_r = outer_r - ring_radial;
    inner_ring_outer_r = inner_r + ring_radial;

    // Ball path
    race_gap_r1 = inner_ring_outer_r + 0.25;
    race_gap_r2 = outer_ring_inner_r - 0.25;
    ball_path_r = (race_gap_r1 + race_gap_r2)/2;

    // Ball size and count
    ball_d = min(2.0, (race_gap_r2 - race_gap_r1) * 0.95);
    ball_r = ball_d/2;
    ball_count = 8;

    // Cage thickness
    cage_th = 0.8;

    difference() {
        union() {
            // Outer ring
            difference() {
                cylinder(h=width, r=outer_r, center=true);
                cylinder(h=width+0.2, r=outer_ring_inner_r, center=true);
            }

            // Inner ring
            difference() {
                cylinder(h=width, r=inner_ring_outer_r, center=true);
                cylinder(h=width+0.2, r=inner_r, center=true);
            }

            // Cage (thin ring around ball path)
            difference() {
                cylinder(h=cage_th, r=ball_path_r + ball_r*0.9, center=true);
                cylinder(h=cage_th+0.2, r=ball_path_r - ball_r*0.9, center=true);
            }

            // Balls
            for (i = [0:ball_count-1]) {
                angle = 360/ball_count * i;
                rotate([0,0,angle])
                    translate([ball_path_r, 0, 0])
                        sphere(r=ball_r);
            }
        }

        // Ensure bore is exact
        cylinder(h=width+0.4, r=inner_r, center=true);
    }
}

bearing_6x13x5();