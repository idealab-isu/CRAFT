$fn=128;

bore_d = 10.0;
outer_d = 30.0;
width = 9.0;

race_wall = 2.0;
race_gap = 0.6;

ball_d = 4.0;
ball_count = 8;

module ring(od, id, w){
    difference(){
        cylinder(d=od, h=w, center=true);
        cylinder(d=id, h=w+0.2, center=true);
    }
}

module ball(d){
    sphere(d=d);
}

module bearing(){
    inner_od = bore_d + 2*race_wall;
    outer_id = outer_d - 2*race_wall;

    ball_path_d = (inner_od + outer_id)/2;
    ball_clear = 0.25;
    groove_d = ball_d + 2*ball_clear;

    difference(){
        union(){
            ring(inner_od, bore_d, width);
            ring(outer_d, outer_id, width);
        }

        for(i=[0:ball_count-1]){
            rotate([0,0,360*i/ball_count])
                translate([ball_path_d/2, 0, 0])
                    sphere(d=groove_d);
        }

        cylinder(d=inner_od + 2*race_gap, h=width+0.2, center=true);
        cylinder(d=outer_id - 2*race_gap, h=width+0.2, center=true);
    }

    for(i=[0:ball_count-1]){
        rotate([0,0,360*i/ball_count])
            translate([ball_path_d/2, 0, 0])
                ball(ball_d);
    }
}

bearing();