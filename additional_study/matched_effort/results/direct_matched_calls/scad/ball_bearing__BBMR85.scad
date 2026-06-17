$fn = 128;

bore_d = 5.0;
od_d   = 8.0;
width  = 2.5;

// Simple ball bearing representation: outer ring + inner ring + ball set + cage
clearance = 0.15;          // radial clearance between rings and balls
ring_gap  = 0.35;          // radial thickness reserved for raceway region
cage_th   = 0.35;          // cage thickness (axial)
ball_d    = 0.9;           // ball diameter (approx for this size)
ball_count = 8;

module ring(outer_d, inner_d, w){
    difference(){
        cylinder(d=outer_d, h=w, center=true);
        cylinder(d=inner_d, h=w+0.2, center=true);
    }
}

module bearing(){
    // Derived diameters
    inner_ring_od = bore_d + 2*ring_gap;
    outer_ring_id = od_d   - 2*ring_gap;

    // Ensure sensible geometry
    inner_ring_od2 = min(inner_ring_od, outer_ring_id - 2*clearance - ball_d);
    outer_ring_id2 = max(outer_ring_id, inner_ring_od2 + 2*clearance + ball_d);

    // Rings
    color([0.75,0.75,0.78])
    ring(od_d, outer_ring_id2, width);

    color([0.75,0.75,0.78])
    ring(inner_ring_od2, bore_d, width);

    // Balls
    ball_path_r = (inner_ring_od2/2 + outer_ring_id2/2)/2;
    color([0.85,0.85,0.88])
    for(i=[0:ball_count-1]){
        rotate([0,0,360*i/ball_count])
            translate([ball_path_r,0,0])
                sphere(d=ball_d);
    }

    // Cage (simple thin ring around balls)
    cage_id = inner_ring_od2 + 2*clearance;
    cage_od = outer_ring_id2 - 2*clearance;
    color([0.55,0.55,0.58])
    difference(){
        cylinder(d=cage_od, h=cage_th, center=true);
        cylinder(d=cage_id, h=cage_th+0.2, center=true);
        // pockets (optional visual)
        for(i=[0:ball_count-1]){
            rotate([0,0,360*i/ball_count])
                translate([ball_path_r,0,0])
                    cylinder(d=ball_d*1.15, h=cage_th+0.4, center=true);
        }
    }
}

bearing();