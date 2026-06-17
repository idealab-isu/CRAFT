// Ball bearing: 5.0mm bore, 9.0mm OD, 2.5mm width
// One connected solid (races + balls + cage fused with tiny overlaps)

$fn = 180;

// Target dimensions
bore_d  = 5.0;
od_d    = 9.0;
width_w = 2.5;

// Bearing detail parameters (kept realistic for this size)
ball_d      = 1.2;
ball_count  = 7;

// Small overlaps to guarantee a single connected manifold
overlap_r = 0.03;   // radial overlap between parts
overlap_z = 0.03;   // axial overlap between parts

// Derived radii
bore_r = bore_d/2;
od_r   = od_d/2;

// Choose a pitch radius that fits balls between bore and OD
// Ensure: bore_r + ball_r < pitch_r < od_r - ball_r
ball_r  = ball_d/2;
pitch_r = (bore_r + od_r)/2;

// Race thicknesses (radial)
inner_race_radial_thk = max(0.55, pitch_r - ball_r - bore_r);
outer_race_radial_thk = max(0.55, od_r - (pitch_r + ball_r));

// Cage (simple ring with pockets)
cage_thk   = 0.45;
cage_width = min(1.6, width_w - 0.4);
pocket_clear = 0.12;

// Helpers
module ring(r_out, r_in, h) {
    difference() {
        cylinder(r=r_out, h=h, center=true);
        cylinder(r=r_in,  h=h + 2*overlap_z, center=true);
    }
}

module ball() {
    sphere(r=ball_r);
}

module ball_set() {
    for (i = [0:ball_count-1]) {
        rotate([0,0,i*360/ball_count])
            translate([pitch_r, 0, 0])
                ball();
    }
}

module cage() {
    cage_r_out = pitch_r + ball_r + cage_thk;
    cage_r_in  = pitch_r - ball_r - cage_thk;

    difference() {
        // Slightly taller to overlap races/balls for connectivity
        cylinder(r=cage_r_out, h=cage_width + 2*overlap_z, center=true);
        cylinder(r=cage_r_in,  h=cage_width + 2*overlap_z + 2*overlap_z, center=true);

        // Ball pockets
        for (i = [0:ball_count-1]) {
            rotate([0,0,i*360/ball_count])
                translate([pitch_r, 0, 0])
                    sphere(r=ball_r + pocket_clear);
        }
    }
}

module inner_race() {
    // Inner race: from bore_r to (pitch_r - ball_r) with a tiny overlap into ball space
    r_out = (pitch_r - ball_r) + overlap_r;
    r_in  = bore_r;

    ring(r_out, r_in, width_w);
}

module outer_race() {
    // Outer race: from (pitch_r + ball_r) to od_r with a tiny overlap into ball space
    r_out = od_r;
    r_in  = (pitch_r + ball_r) - overlap_r;

    ring(r_out, r_in, width_w);
}

// Final connected solid
union() {
    outer_race();
    inner_race();
    ball_set();
    cage();
}