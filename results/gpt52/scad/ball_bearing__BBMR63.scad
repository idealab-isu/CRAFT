$fn=96;

bore_d = 3.0;
od_d = 6.0;
width = 2.5;

race_wall = 0.55;
race_depth = 0.55;
ball_d = 0.75;
ball_count = 8;

module ring(od, id, w){
    difference(){
        cylinder(d=od, h=w, center=true);
        cylinder(d=id, h=w+0.2, center=true);
    }
}

module raceway_profile(r_mid, depth, ball_r){
    rotate_extrude(convexity=10)
        translate([r_mid, 0, 0])
            circle(r=ball_r + depth, $fn=64);
}

module balls(r_center, ball_d, count, w){
    for(i=[0:count-1]){
        rotate([0,0,360*i/count])
            translate([r_center,0,0])
                sphere(d=ball_d, $fn=64);
    }
}

module bearing(){
    r_bore = bore_d/2;
    r_od = od_d/2;

    r_inner_od = r_bore + race_wall;
    r_outer_id = r_od - race_wall;

    r_ball_center = (r_inner_od + r_outer_id)/2;

    union(){
        difference(){
            union(){
                ring(od=2*r_inner_od, id=bore_d, w=width);
                ring(od=od_d, id=2*r_outer_id, w=width);
            }
            raceway_profile(r_mid=r_ball_center, depth=race_depth, ball_r=ball_d/2);
        }
        balls(r_center=r_ball_center, ball_d=ball_d, count=ball_count, w=width);
    }
}

bearing();