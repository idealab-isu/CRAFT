$fn=128;

bore_d = 16.0;
od_d = 28.0;
len = 37.0;

shell_wall = (od_d - bore_d)/2;
lip_len = 1.0;
lip_extra = 0.6;
groove_w = 1.6;
groove_depth = 0.8;

module ring(od, id, h){
    difference(){
        cylinder(d=od, h=h, center=true);
        cylinder(d=id, h=h+0.2, center=true);
    }
}

module linear_bearing(){
    difference(){
        union(){
            cylinder(d=od_d, h=len, center=true);
            translate([0,0, (len/2 - lip_len/2)]) ring(od=od_d + 2*lip_extra, id=bore_d, h=lip_len);
            translate([0,0, -(len/2 - lip_len/2)]) ring(od=od_d + 2*lip_extra, id=bore_d, h=lip_len);
        }
        cylinder(d=bore_d, h=len+0.4, center=true);
        translate([0,0, (len/2 - lip_len - groove_w/2)]) ring(od=od_d+0.2, id=od_d - 2*groove_depth, h=groove_w);
        translate([0,0, -(len/2 - lip_len - groove_w/2)]) ring(od=od_d+0.2, id=od_d - 2*groove_depth, h=groove_w);
    }
}

linear_bearing();