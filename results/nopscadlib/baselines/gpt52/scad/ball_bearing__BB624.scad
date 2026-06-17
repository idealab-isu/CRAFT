$fn=128;

bore_d = 4.0;
od_d = 13.0;
width = 5.0;

race_thickness = 1.2;
ball_d = 1.6;
ball_count = 8;

module ring(od, id, w){
    difference(){
        cylinder(d=od, h=w, center=true);
        cylinder(d=id, h=w+0.2, center=true);
    }
}

module ball_bearing(){
    union(){
        ring(od_d, od_d - 2*race_thickness, width);
        ring(bore_d + 2*race_thickness, bore_d, width);

        for(i=[0:ball_count-1]){
            rotate([0,0,360*i/ball_count])
                translate([(bore_d/2 + od_d/2)/2, 0, 0])
                    sphere(d=ball_d);
        }
    }
}

ball_bearing();