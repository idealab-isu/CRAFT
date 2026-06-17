$fn=128;

bore_d = 3.0;
od_d = 8.0;
width = 3.0;

clearance = 0.15;
race_wall = 0.55;
ball_d = 1.2;
ball_count = 8;

module ring(od, id, w){
    difference(){
        cylinder(d=od, h=w, center=true);
        cylinder(d=id, h=w+0.4, center=true);
    }
}

module ball(d){
    sphere(d=d);
}

module bearing(){
    inner_od = bore_d + 2*race_wall;
    outer_id = od_d - 2*race_wall;

    ball_path_d = (inner_od + outer_id)/2;
    pocket_d = ball_d + clearance;

    difference(){
        union(){
            ring(inner_od, bore_d, width);
            ring(od_d, outer_id, width);
            for(i=[0:ball_count-1]){
                rotate([0,0,360*i/ball_count])
                    translate([ball_path_d/2,0,0])
                        ball(ball_d);
            }
        }
        for(i=[0:ball_count-1]){
            rotate([0,0,360*i/ball_count])
                translate([ball_path_d/2,0,0])
                    sphere(d=pocket_d);
        }
    }
}

bearing();