$fn = 180;

bore_d = 4.0;
od_d   = 13.0;
width  = 5.0;

// Simple parametric ball bearing representation:
// - Outer ring
// - Inner ring
// - Ball set + cage (approximate)

inner_ring_od = 7.0;     // approximate for 4x13x5 bearing
outer_ring_id = 10.0;    // approximate race ID
ball_d        = 1.6;     // approximate ball diameter
clearance     = 0.15;    // small clearance for visuals

module ring(od, id, w){
    difference(){
        cylinder(d=od, h=w, center=true);
        cylinder(d=id, h=w+0.2, center=true);
    }
}

module bearing(){
    union(){
        // Outer ring
        ring(od_d, outer_ring_id, width);

        // Inner ring
        ring(inner_ring_od, bore_d, width);

        // Cage (thin ring around ball path)
        cage_od = outer_ring_id - 0.4;
        cage_id = inner_ring_od + 0.4;
        cage_w  = width * 0.55;
        color([0.7,0.7,0.7])
            ring(cage_od, cage_id, cage_w);

        // Balls
        ball_path_r = (outer_ring_id/2 + inner_ring_od/2)/2;
        n_balls = 9;
        for(i=[0:n_balls-1]){
            a = 360*i/n_balls;
            rotate([0,0,a])
                translate([ball_path_r,0,0])
                    color([0.85,0.85,0.9])
                        sphere(d=ball_d - clearance);
        }
    }
}

bearing();