$fn=128;

bore_d = 3.0;
od_d = 8.0;
width = 3.0;

flange_d = 9.5;
flange_th = 0.6;

ring_wall = 1.0;
inner_ring_od = bore_d + 2*ring_wall;

race_clear = 0.25;
race_depth = 0.55;

ball_d = 1.0;
ball_count = 7;

module ring_with_race(od, id, w, race_r, race_z, race_depth){
    difference(){
        cylinder(d=od, h=w, center=true);
        cylinder(d=id, h=w+0.4, center=true);
        rotate_extrude(convexity=10)
            translate([race_r, race_z, 0])
                circle(r=race_depth, $fn=64);
    }
}

module balls(ball_d, count, r, z){
    for(i=[0:count-1]){
        rotate([0,0,360*i/count])
            translate([r,0,z])
                sphere(d=ball_d, $fn=64);
    }
}

module flanged_bearing(){
    union(){
        translate([0,0,(width/2 - flange_th/2)])
            cylinder(d=flange_d, h=flange_th, center=true);

        ring_with_race(
            od=od_d,
            id=inner_ring_od,
            w=width,
            race_r=(od_d/2 - ring_wall/2),
            race_z=0,
            race_depth=race_depth
        );

        ring_with_race(
            od=inner_ring_od,
            id=bore_d,
            w=width,
            race_r=(inner_ring_od/2 - ring_wall/2),
            race_z=0,
            race_depth=race_depth
        );

        balls(
            ball_d=ball_d,
            count=ball_count,
            r=(inner_ring_od/2 + (od_d/2 - inner_ring_od/2)/2),
            z=0
        );
    }
}

flanged_bearing();