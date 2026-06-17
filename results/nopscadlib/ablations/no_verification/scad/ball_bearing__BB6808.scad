// Ball bearing: 40mm bore, 52mm OD, 7mm width
// Single connected solid (races + balls + cage bridges)

$fn = 128;

// Target dimensions
bore_diameter_mm  = 40.0;
outer_diameter_mm = 52.0;
width_mm          = 7.0;

// Derived radii
bore_r  = bore_diameter_mm/2;
outer_r = outer_diameter_mm/2;

// Small overlap to guarantee connectivity
overlap = 0.25;

// Race geometry (kept within OD/ID)
outer_race_radial = 2.2;   // thickness of outer race ring
inner_race_radial = 2.2;   // thickness of inner race ring

// Ball set
ball_diameter_mm = 3.2;
ball_r = ball_diameter_mm/2;
ball_count = 10;

// Ball pitch radius (between races)
inner_race_outer_r = bore_r + inner_race_radial;
outer_race_inner_r = outer_r - outer_race_radial;
ball_pitch_r = (inner_race_outer_r + outer_race_inner_r)/2;

// Cage (bridges that connect balls to races so model is one solid)
cage_thickness_z = 1.2; // axial thickness of cage bridges
cage_radial_w    = 0.9; // radial width of each bridge
cage_overlap_r   = 0.35; // how much bridges intrude into races/balls

module ring(r_out, r_in, h) {
    difference() {
        cylinder(r=r_out, h=h, center=true);
        cylinder(r=r_in,  h=h + 2*overlap, center=true);
    }
}

module bearing() {
    union() {
        // Outer race (OD fixed at 52mm)
        ring(outer_r, outer_r - outer_race_radial, width_mm);

        // Inner race (bore fixed at 40mm)
        ring(bore_r + inner_race_radial, bore_r, width_mm);

        // Balls + cage bridges (all fused into one solid)
        for (i = [0:ball_count-1]) {
            rotate([0,0,i*360/ball_count]) {
                // Ball
                translate([ball_pitch_r, 0, 0])
                    sphere(r=ball_r);

                // Cage bridge: a small radial bar that overlaps ball and both races
                // Positioned at ball center, spans from inner race outer surface to outer race inner surface
                // and overlaps into both by cage_overlap_r to ensure union connectivity.
                translate([(inner_race_outer_r + outer_race_inner_r)/2, 0, 0])
                    cube([
                        (outer_race_inner_r - inner_race_outer_r) + 2*cage_overlap_r,
                        cage_radial_w,
                        cage_thickness_z
                    ], center=true);
            }
        }

        // Optional thin center web to further guarantee single solid without changing OD/ID
        // (kept inside the annulus between races)
        ring(outer_race_inner_r - 0.2, inner_race_outer_r + 0.2, 0.6);
    }
}

bearing();