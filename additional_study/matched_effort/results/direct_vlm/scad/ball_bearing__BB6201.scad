$fn = 180;

bore_d = 12.0;
od_d   = 32.0;
width  = 10.0;

// Simple parametric ball bearing representation (rings + balls + cage gap)
clearance_radial = 0.25;   // small clearance between rings and balls
race_thickness   = 3.0;    // radial thickness of each ring
race_lip         = 0.8;    // axial lip thickness to suggest race shoulders

ball_count = 8;
ball_d = 4.2;

module ring(ri, ro, w) {
    difference() {
        cylinder(d=2*ro, h=w, center=true);
        cylinder(d=2*ri, h=w+0.2, center=true);
    }
}

module race_profile(ri, ro, w) {
    // Add slight shoulders by subtracting a wider middle section
    difference() {
        ring(ri, ro, w);
        // create a shallow groove region (visual cue)
        cylinder(d=2*(ro - race_thickness*0.35), h=w - 2*race_lip, center=true);
    }
}

module bearing() {
    ri = bore_d/2;
    ro = od_d/2;

    // Define inner and outer ring radial extents
    inner_ro = ri + race_thickness;
    outer_ri = ro - race_thickness;

    // Ball path radius roughly centered between rings
    ball_path_r = (inner_ro + outer_ri)/2;

    // Rings
    color([0.75,0.75,0.78]) race_profile(ri, inner_ro, width);
    color([0.75,0.75,0.78]) race_profile(outer_ri, ro, width);

    // Balls
    for (i = [0:ball_count-1]) {
        a = 360/ball_count * i;
        translate([ball_path_r*cos(a), ball_path_r*sin(a), 0])
            color([0.85,0.85,0.88])
                sphere(d=ball_d);
    }

    // Simple cage (thin ring) with pockets implied by subtraction
    cage_th = 1.2;
    cage_ri = ball_path_r - ball_d/2 - clearance_radial;
    cage_ro = ball_path_r + ball_d/2 + clearance_radial;

    difference() {
        color([0.55,0.55,0.58])
            ring(cage_ri, cage_ro, cage_th);
        for (i = [0:ball_count-1]) {
            a = 360/ball_count * i;
            translate([ball_path_r*cos(a), ball_path_r*sin(a), 0])
                cylinder(d=ball_d + 0.8, h=cage_th+0.4, center=true);
        }
    }
}

bearing();