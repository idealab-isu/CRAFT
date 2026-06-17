$fn = 180;

bore_d = 8.0;
od_d   = 22.0;
width  = 7.0;

// Simple parametric ball bearing approximation (608 size):
// - Outer ring and inner ring with race grooves
// - Ball set (no cage/shields)

clearance = 0.25;          // radial clearance between rings
race_groove_r = 1.15;      // groove radius for raceway (approx)
ball_d = 3.5;              // typical 608 ball diameter
ball_r = ball_d/2;

inner_ring_od = 12.0;      // typical 608 inner ring OD
outer_ring_id = 18.0;      // typical 608 outer ring ID

// Clamp to ensure valid geometry if parameters are changed
inner_ring_od = min(inner_ring_od, outer_ring_id - 2*clearance);
outer_ring_id = max(outer_ring_id, inner_ring_od + 2*clearance);

module ring(od, id, w, groove_center_r, groove_r){
    difference(){
        cylinder(d=od, h=w, center=true);
        cylinder(d=id, h=w+0.4, center=true);

        // Raceway groove (torus-like cut via rotate_extrude of a circle)
        rotate_extrude(convexity=10)
            translate([groove_center_r, 0, 0])
                circle(r=groove_r);
    }
}

module bearing(){
    // Groove center radius roughly midway between rings
    groove_center_r = (inner_ring_od/2 + outer_ring_id/2)/2;

    // Outer ring
    ring(od_d, outer_ring_id, width, groove_center_r, race_groove_r);

    // Inner ring
    ring(inner_ring_od, bore_d, width, groove_center_r, race_groove_r);

    // Balls
    ball_path_r = groove_center_r;
    for(i = [0:7]){
        rotate([0,0, i*360/8])
            translate([ball_path_r, 0, 0])
                sphere(d=ball_d);
    }
}

bearing();