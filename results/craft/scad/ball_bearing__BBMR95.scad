// Ball bearing: 5.0mm bore, 9.0mm OD, 3.0mm width
// Single connected solid (balls fused via a thin cage ring)
// No text/labels

$fn = 128;

// Parameters (requested)
bore_diameter_mm  = 5.0;
outer_diameter_mm = 9.0;
width_mm          = 3.0;

// Detailing parameters
eps_mm = 0.02;                 // small overlap to ensure manifold unions
race_radial_thickness_mm = 0.9;
shield_thickness_mm = 0.35;
shield_radial_overlap_mm = 0.35;

ball_diameter_mm = 1.2;
ball_count = 8;

// Derived radii
bore_r  = bore_diameter_mm/2;
outer_r = outer_diameter_mm/2;

// Keep races within OD/ID
inner_race_outer_r = bore_r + race_radial_thickness_mm;
outer_race_inner_r = outer_r - race_radial_thickness_mm;

// Ball path radius centered in the annulus between races
ball_center_radius_mm = (inner_race_outer_r + outer_race_inner_r)/2;

// Cage ring to make the whole model ONE connected solid
cage_thickness_z_mm = 0.35;    // thin ring in the middle
cage_radial_mm = 0.18;         // small radial thickness so it doesn't fill the gap

module ring(r_out, r_in, h, center=true) {
    difference() {
        cylinder(r=r_out, h=h, center=center);
        cylinder(r=r_in,  h=h + 2*eps_mm, center=center);
    }
}

module outer_race() {
    ring(outer_r, outer_race_inner_r, width_mm, center=true);
}

module inner_race() {
    ring(inner_race_outer_r, bore_r, width_mm, center=true);
}

module shield_disc(zpos) {
    // Slightly overlaps races to avoid floating parts
    shield_r_out = outer_race_inner_r + shield_radial_overlap_mm;
    shield_r_in  = inner_race_outer_r - shield_radial_overlap_mm;
    translate([0,0,zpos])
        ring(shield_r_out, shield_r_in, shield_thickness_mm, center=true);
}

module bearing_ball_at(angle_deg) {
    rotate([0,0,angle_deg])
        translate([ball_center_radius_mm, 0, 0])
            sphere(r=ball_diameter_mm/2);
}

module cage_ring() {
    // Thin ring at mid-plane that touches balls (fuses them) and stays inside the gap
    cage_r_out = ball_center_radius_mm + cage_radial_mm;
    cage_r_in  = ball_center_radius_mm - cage_radial_mm;
    ring(cage_r_out, cage_r_in, cage_thickness_z_mm, center=true);
}

module ball_bearing() {
    union() {
        // Races
        outer_race();
        inner_race();

        // Shields (placed just inside faces, with overlap)
        z_shield = width_mm/2 - shield_thickness_mm/2 - eps_mm;
        shield_disc( z_shield);
        shield_disc(-z_shield);

        // Balls + cage (ensures one connected solid)
        cage_ring();
        for (i = [0:ball_count-1]) {
            bearing_ball_at(i * 360/ball_count);
        }
    }
}

ball_bearing();