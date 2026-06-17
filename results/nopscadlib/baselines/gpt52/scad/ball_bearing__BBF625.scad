$fn=128;

bore_d = 5.0;
od_d = 16.0;
width = 5.0;

flange_d = 18.0;
flange_th = 1.0;

ring_chamfer = 0.4;

module chamfered_ring(od, id, h, c){
    difference(){
        union(){
            cylinder(d=od-2*c, h=h, center=true);
            translate([0,0,(h/2 - c/2)]) cylinder(d1=od, d2=od-2*c, h=c, center=true);
            translate([0,0,-(h/2 - c/2)]) cylinder(d1=od-2*c, d2=od, h=c, center=true);
        }
        cylinder(d=id, h=h+2, center=true);
    }
}

module bearing_body(){
    union(){
        chamfered_ring(od_d, bore_d, width, ring_chamfer);
        translate([0,0,(width/2 - flange_th/2)])
            difference(){
                cylinder(d=flange_d, h=flange_th, center=true);
                cylinder(d=bore_d, h=flange_th+2, center=true);
            }
    }
}

module ball(d){
    sphere(d=d);
}

module ball_set(n, r, d, z){
    for(i=[0:n-1]){
        rotate([0,0,360*i/n])
            translate([r,0,z])
                ball(d);
    }
}

module bearing(){
    ball_count = 10;
    ball_d = 2.2;
    race_r = (bore_d/2 + od_d/2)/2;
    zpos = 0;

    difference(){
        union(){
            bearing_body();
            ball_set(ball_count, race_r, ball_d, zpos);
        }
        cylinder(d=bore_d, h=width+flange_th+4, center=true);
    }
}

bearing();