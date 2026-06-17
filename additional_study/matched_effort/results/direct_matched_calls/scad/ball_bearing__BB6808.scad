$fn = 180;

bore_d = 40.0;
od_d   = 52.0;
width  = 7.0;

// Simple deep-groove ball bearing approximation
// (rings + balls + cage)

module ring(od, id, w){
    difference(){
        cylinder(d=od, h=w, center=true);
        cylinder(d=id, h=w+0.4, center=true);
    }
}

module bearing_approx(bore_d, od_d, width){
    // Ring thickness and race geometry (approx)
    ring_radial = (od_d - bore_d)/2;
    ring_wall   = max(1.2, ring_radial*0.28);          // radial thickness of each ring
    gap_radial  = max(0.6, ring_radial*0.10);          // clearance between rings

    inner_od = bore_d + 2*ring_wall;
    outer_id = od_d   - 2*ring_wall;

    // Ball sizing and placement
    race_mid_r = (inner_od/2 + outer_id/2)/2;
    ball_d = min(width*0.72, (outer_id - inner_od)*0.72);
    ball_d = max(2.0, ball_d);

    // Choose ball count based on circumference and ball size
    n = max(8, floor((2*PI*race_mid_r) / (ball_d*1.25)));

    // Cage (very simple)
    cage_th = max(0.8, width*0.18);
    cage_od = outer_id - gap_radial;
    cage_id = inner_od + gap_radial;

    union(){
        // Outer ring
        ring(od_d, outer_id, width);

        // Inner ring
        ring(inner_od, bore_d, width);

        // Cage
        difference(){
            cylinder(d=cage_od, h=cage_th, center=true);
            cylinder(d=cage_id, h=cage_th+0.4, center=true);

            // Ball pockets
            for(i=[0:n-1]){
                rotate([0,0,360*i/n])
                    translate([race_mid_r,0,0])
                        sphere(d=ball_d*1.05);
            }
        }

        // Balls
        for(i=[0:n-1]){
            rotate([0,0,360*i/n])
                translate([race_mid_r,0,0])
                    sphere(d=ball_d);
        }
    }
}

bearing_approx(bore_d, od_d, width);