$fn=128;

bore_d = 6.0;
od_d = 16.0;
width = 5.0;

race_thickness = 1.6;
ball_d = 2.0;
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
    union(){
        ring(od_d, od_d - 2*race_thickness, width);
        ring(bore_d + 2*race_thickness, bore_d, width);

        for(i=[0:ball_count-1]){
            rotate([0,0,360*i/ball_count])
                translate([(bore_d/2 + od_d/2)/2, 0, 0])
                    ball(ball_d);
        }
    }
}

bearing();