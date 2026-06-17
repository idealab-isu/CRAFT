$fn = 128;

bore_d = 5.0;
od_d   = 8.0;
width  = 2.5;

// Simple ball bearing representation: outer ring + inner ring + ball set + cages
clearance = 0.15;          // radial clearance between rings and balls
race_depth = 0.55;         // approximate race groove depth
cage_thk = 0.35;           // cage thickness (each side)
ball_count = 8;

module ring(od, id, w){
    difference(){
        cylinder(d=od, h=w, center=true);
        cylinder(d=id, h=w+0.2, center=true);
    }
}

module bearing(){
    // Ring thickness allocation
    ring_rad_thk = (od_d - bore_d)/4; // approximate
    inner_od = bore_d + 2*ring_rad_thk;
    outer_id = od_d   - 2*ring_rad_thk;

    // Ball geometry
    ball_d = min(width*0.75, (outer_id - inner_od) - 2*clearance);
    ball_d = max(ball_d, 0.6); // safety
    ball_r = ball_d/2;

    pitch_d = (inner_od + outer_id)/2;
    pitch_r = pitch_d/2;

    // Outer ring with race groove
    difference(){
        ring(od_d, outer_id, width);
        rotate_extrude(angle=360)
            translate([od_d/2 - ring_rad_thk, 0, 0])
                circle(r=race_depth, $fn=64);
    }

    // Inner ring with race groove
    difference(){
        ring(inner_od, bore_d, width);
        rotate_extrude(angle=360)
            translate([bore_d/2 + ring_rad_thk, 0, 0])
                circle(r=race_depth, $fn=64);
    }

    // Balls
    for(i=[0:ball_count-1]){
        ang = 360*i/ball_count;
        rotate([0,0,ang])
            translate([pitch_r,0,0])
                sphere(d=ball_d);
    }

    // Cages (simple thin rings on both sides)
    cage_id = inner_od + clearance*2;
    cage_od = outer_id - clearance*2;
    translate([0,0, (width/2 - cage_thk/2)])
        ring(cage_od, cage_id, cage_thk);
    translate([0,0, -(width/2 - cage_thk/2)])
        ring(cage_od, cage_id, cage_thk);
}

bearing();