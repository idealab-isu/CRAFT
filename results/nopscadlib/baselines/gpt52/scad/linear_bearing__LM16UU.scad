$fn=128;

bore_d = 16.0;
od_d = 28.0;
len = 37.0;

seal_recess_d = 26.0;
seal_recess_depth = 1.2;

groove_d = 25.0;
groove_w = 1.2;
groove_offset = 6.0;

module ring_groove(d, w, zpos){
    translate([0,0,zpos])
        cylinder(d=d, h=w, center=true);
}

module end_recess(d, depth, zsign){
    translate([0,0,zsign*(len/2 - depth/2)])
        cylinder(d=d, h=depth, center=true);
}

module linear_bearing(){
    difference(){
        cylinder(d=od_d, h=len, center=true);
        cylinder(d=bore_d, h=len+0.2, center=true);

        end_recess(seal_recess_d, seal_recess_depth, 1);
        end_recess(seal_recess_d, seal_recess_depth, -1);

        ring_groove(groove_d, groove_w, len/2 - groove_offset);
        ring_groove(groove_d, groove_w, -(len/2 - groove_offset));
    }
}

linear_bearing();