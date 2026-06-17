$fn = 180;

bore_d = 6.0;
od_d   = 16.0;
width  = 5.0;

// Simple visual ball bearing model (rings + balls + cage gap)
clearance_radial = 0.25;   // radial clearance between rings and balls
race_thickness   = 1.6;    // thickness of each ring wall
ball_d           = 2.2;    // ball diameter (visual approximation)
ball_count       = 8;      // typical for this size (visual)
cage_gap         = 0.6;    // axial gap between rings (visual)

module ring(outer_d, inner_d, w){
    difference(){
        cylinder(d=outer_d, h=w, center=true);
        cylinder(d=inner_d, h=w+0.2, center=true);
    }
}

module bearing(){
    // Outer ring
    outer_inner_d = od_d - 2*race_thickness;
    ring(od_d, outer_inner_d, width);

    // Inner ring
    inner_outer_d = bore_d + 2*race_thickness;
    ring(inner_outer_d, bore_d, width);

    // Balls
    pitch_d = (outer_inner_d + inner_outer_d)/2 - 2*clearance_radial;
    for(i = [0:ball_count-1]){
        rotate([0,0,360*i/ball_count])
            translate([pitch_d/2, 0, 0])
                sphere(d=ball_d);
    }

    // Simple cage (thin band around balls)
    cage_outer_d = pitch_d + ball_d*0.9;
    cage_inner_d = pitch_d - ball_d*0.9;
    cage_w = max(0.8, width - 2*cage_gap);
    color([0.7,0.7,0.7])
    difference(){
        cylinder(d=cage_outer_d, h=cage_w, center=true);
        cylinder(d=cage_inner_d, h=cage_w+0.2, center=true);
    }
}

bearing();