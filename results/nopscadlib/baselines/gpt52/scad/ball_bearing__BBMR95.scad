$fn=128;

bore_d = 5.0;
od_d = 9.0;
width = 3.0;

race_th = 0.8;
ball_d = 1.0;
ball_count = 8;

module ring(od, id, w){
    difference(){
        cylinder(d=od, h=w, center=true);
        cylinder(d=id, h=w+0.2, center=true);
    }
}

module ball_bearing(){
    union(){
        ring(od_d, bore_d, width);

        difference(){
            cylinder(d=od_d-2*race_th, h=width, center=true);
            cylinder(d=bore_d+2*race_th, h=width+0.2, center=true);
        }

        for(i=[0:ball_count-1]){
            rotate([0,0,360*i/ball_count])
                translate([(bore_d/2 + od_d/2)/2, 0, 0])
                    sphere(d=ball_d);
        }
    }
}

ball_bearing();