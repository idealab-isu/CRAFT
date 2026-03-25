$fn=128;

bore_d = 3.0;
od_d = 9.0;
width = 4.0;

race_wall = 1.0;
race_depth = 0.9;
ball_d = 1.2;
ball_count = 8;

module ring(od, id, w){
    difference(){
        cylinder(d=od, h=w, center=true);
        cylinder(d=id, h=w+0.2, center=true);
    }
}

module bearing_races(){
    difference(){
        ring(od_d, bore_d, width);
        translate([0,0, width/2 - race_depth/2])
            ring(od_d - 2*race_wall, bore_d + 2*race_wall, race_depth);
        translate([0,0,-width/2 + race_depth/2])
            ring(od_d - 2*race_wall, bore_d + 2*race_wall, race_depth);
    }
}

module balls(){
    pitch_d = (bore_d + od_d)/2;
    for(i=[0:ball_count-1]){
        rotate([0,0, i*360/ball_count])
            translate([pitch_d/2, 0, 0])
                sphere(d=ball_d);
    }
}

union(){
    bearing_races();
    balls();
}