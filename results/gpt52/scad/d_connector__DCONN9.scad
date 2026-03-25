$fn=64;

module d_profile(width=20, height=12, depth=10){
    r = height/2;
    union(){
        translate([0,0,0]) cube([width - r, height, depth], center=true);
        translate([(width/2 - r),0,0]) cylinder(h=depth, r=r, center=true);
    }
}

module d_hole(width=16, height=8, depth=20){
    r = height/2;
    union(){
        cube([width - r, height, depth], center=true);
        translate([(width/2 - r),0,0]) cylinder(h=depth, r=r, center=true);
    }
}

module d_connector(body_w=26, body_h=16, body_d=18, bore_w=20, bore_h=12, bore_d=22, flange_t=3, flange_w=34, flange_h=22, screw_r=1.8, screw_offset_y=7){
    difference(){
        union(){
            d_profile(width=body_w, height=body_h, depth=body_d);
            translate([0,0,(body_d/2 + flange_t/2)]) d_profile(width=flange_w, height=flange_h, depth=flange_t);
        }
        d_hole(width=bore_w, height=bore_h, depth=bore_d);
        translate([0, screw_offset_y, (body_d/2 + flange_t/2)]) cylinder(h=flange_t+2, r=screw_r, center=true);
        translate([0,-screw_offset_y, (body_d/2 + flange_t/2)]) cylinder(h=flange_t+2, r=screw_r, center=true);
    }
}

d_connector();