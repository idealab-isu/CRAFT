$fn = 128;

bore_d = 5.0;
od_d   = 9.0;
width  = 3.0;

// Simple ball bearing representation: outer ring + inner ring + balls + cage gap
clearance = 0.15;          // radial clearance between rings and balls
ball_d    = 1.2;           // approximate ball diameter for this size
race_gap  = ball_d + 2*clearance;

inner_od = bore_d + 2*(race_gap*0.55);
outer_id = od_d   - 2*(race_gap*0.55);

inner_od = min(inner_od, outer_id - 0.6); // ensure positive ring thickness
outer_id = max(outer_id, inner_od + 0.6);

module ring(id, od, w){
    difference(){
        cylinder(d=od, h=w, center=true);
        cylinder(d=id, h=w+0.2, center=true);
    }
}

module bearing(){
    // Rings
    ring(bore_d, inner_od, width);
    ring(outer_id, od_d, width);

    // Balls
    pitch_d = (inner_od + outer_id)/2;
    nballs = max(6, floor(PI*pitch_d/(ball_d*1.35)));
    for(i=[0:nballs-1]){
        rotate([0,0,360*i/nballs])
            translate([pitch_d/2,0,0])
                sphere(d=ball_d);
    }

    // Simple cage (thin band with pockets)
    cage_th = 0.5;
    cage_id = inner_od + clearance*2;
    cage_od = outer_id - clearance*2;
    difference(){
        ring(cage_id, cage_od, cage_th);
        for(i=[0:nballs-1]){
            rotate([0,0,360*i/nballs])
                translate([pitch_d/2,0,0])
                    cylinder(d=ball_d*1.15, h=cage_th+0.4, center=true);
        }
    }
}

bearing();