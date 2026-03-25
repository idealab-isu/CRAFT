$fn=128;

bore_d = 12.0;
od_d = 32.0;
width = 10.0;

inner_ring_od = 18.0;
outer_ring_id = 26.0;

ball_d = 4.0;
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

module balls(count, pitch_d, d){
    for(i=[0:count-1]){
        rotate([0,0,360*i/count])
            translate([pitch_d/2,0,0])
                ball(d);
    }
}

module bearing(){
    union(){
        ring(inner_ring_od, bore_d, width);
        ring(od_d, outer_ring_id, width);
        balls(ball_count, (inner_ring_od + outer_ring_id)/2, ball_d);
    }
}

bearing();