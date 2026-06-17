$fn = 128;

bore_d = 3.0;
od_d   = 6.0;
width  = 2.5;

// Simple visual ball bearing approximation: outer ring + inner ring + balls + cage gap
clearance = 0.15;          // radial clearance between rings and balls
race_th   = 0.65;          // ring radial thickness
race_lip  = 0.25;          // axial lip thickness (keeps balls visually contained)

ball_d    = 0.75;
ball_count = 8;

module ring(outer_d, inner_d, w){
    difference(){
        cylinder(d=outer_d, h=w, center=true);
        cylinder(d=inner_d, h=w+0.2, center=true);
    }
}

module bearing(){
    // Outer ring
    outer_inner_d = od_d - 2*race_th;
    difference(){
        ring(od_d, outer_inner_d, width);
        // race groove (visual)
        cylinder(d=outer_inner_d - 2*clearance, h=width - 2*race_lip, center=true);
    }

    // Inner ring
    inner_outer_d = bore_d + 2*race_th;
    difference(){
        ring(inner_outer_d, bore_d, width);
        // race groove (visual)
        cylinder(d=inner_outer_d + 2*clearance, h=width - 2*race_lip, center=true);
    }

    // Balls
    pitch_d = (outer_inner_d + inner_outer_d)/2;
    for(i=[0:ball_count-1]){
        rotate([0,0,360*i/ball_count])
            translate([pitch_d/2,0,0])
                sphere(d=ball_d);
    }

    // Simple cage (thin ring between races)
    cage_od = outer_inner_d - clearance;
    cage_id = inner_outer_d + clearance;
    cage_w  = width - 2*race_lip;
    color([0.7,0.7,0.7])
    difference(){
        ring(cage_od, cage_id, cage_w);
        // pockets (visual)
        for(i=[0:ball_count-1]){
            rotate([0,0,360*i/ball_count])
                translate([pitch_d/2,0,0])
                    cylinder(d=ball_d*1.15, h=cage_w+0.2, center=true);
        }
    }
}

bearing();