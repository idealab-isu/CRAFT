$fn=128;

bore_d = 40.0;
od_d = 52.0;
width = 7.0;

race_th = 1.2;
ball_d = 2.2;
ball_count = 12;

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
    union(){
        ring(od_d, bore_d, width);

        translate([0,0,0])
        ring(od_d - 2*race_th, bore_d + 2*race_th, width);

        for(i=[0:ball_count-1]){
            rotate([0,0,360*i/ball_count])
                translate([(bore_d/2 + od_d/2)/2, 0, 0])
                    ball(ball_d);
        }
    }
}

bearing();