// Ball bearing: 4.0mm bore, 13.0mm outer diameter, 5.0mm width
// One connected solid (rings + balls fused with small overlap)
// Fixes: circular bore (higher $fn), true spheres, verifiable dimensions

$fn = 128;

// Requested dimensions
bore_d  = 4.0;
outer_d = 13.0;
width   = 5.0;

// Geometry controls (kept reasonable for 4x13x5 bearing look)
ring_radial_thk = 1.5;     // ring thickness (radial)
ball_count      = 8;
ball_d          = 1.6;     // ball diameter (visual)
race_clear      = 0.15;    // clearance from rings to ball centerline
overlap         = 0.12;    // small fusion overlap to ensure ONE connected solid

// Derived radii
bore_r  = bore_d/2;
outer_r = outer_d/2;

inner_ring_outer_r = bore_r + ring_radial_thk;
outer_ring_inner_r = outer_r - ring_radial_thk;

// Ball pitch radius (centerline between rings, with slight clearance)
ball_pitch_r = (inner_ring_outer_r + outer_ring_inner_r)/2;

// Ensure balls fit between rings
// (If you change parameters, keep: ball_pitch_r - ball_d/2 >= inner_ring_outer_r - overlap
//  and ball_pitch_r + ball_d/2 <= outer_ring_inner_r + overlap)

module ring(r_outer, r_inner, h){
    difference() {
        cylinder(r=r_outer, h=h, center=true);
        cylinder(r=r_inner, h=h + 2*overlap, center=true);
    }
}

module balls(){
    for (i = [0:ball_count-1]) {
        rotate([0,0,i*360/ball_count])
            translate([ball_pitch_r, 0, 0])
                sphere(r=ball_d/2);
    }
}

module bearing(){
    union() {
        // Outer ring: exact OD and width
        ring(outer_r, outer_ring_inner_r, width);

        // Inner ring: exact bore and width
        ring(inner_ring_outer_r, bore_r, width);

        // Balls: fused slightly into rings to make one connected solid
        // (overlap achieved by slightly increasing effective ball radius)
        for (i = [0:ball_count-1]) {
            rotate([0,0,i*360/ball_count])
                translate([ball_pitch_r, 0, 0])
                    sphere(r=ball_d/2 + overlap);
        }
    }
}

bearing();