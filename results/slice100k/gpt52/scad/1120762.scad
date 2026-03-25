$fn=64;

sx = 13.2;
sy = 12.0;
sz = 6.3;

arm_len = 3.6;
arm_w   = 2.2;
arm_t   = sz;

hub_x = sx - 2*arm_len;
hub_y = sy - 2*arm_len;
hub_z = sz;

fillet_r = 0.7;

module rounded_box(size=[10,10,10], r=0.5, center=true){
    x=size[0]; y=size[1]; z=size[2];
    rr = min(r, x/2, y/2, z/2);
    translate(center ? [-x/2,-y/2,-z/2] : [0,0,0])
    minkowski(){
        cube([x-2*rr, y-2*rr, z-2*rr], center=false);
        sphere(r=rr);
    }
}

module arm_x(sign=1){
    translate([sign*(hub_x/2 + arm_len/2), 0, 0])
        rounded_box([arm_len, arm_w, arm_t], r=fillet_r, center=true);
}

module arm_y(sign=1){
    translate([0, sign*(hub_y/2 + arm_len/2), 0])
        rounded_box([arm_w, arm_len, arm_t], r=fillet_r, center=true);
}

module arm_diag(sxgn=1, sygn=1){
    ang = atan2(sygn, sxgn);
    translate([sxgn*(hub_x/2), sygn*(hub_y/2), 0])
        rotate([0,0,ang])
            translate([arm_len/2, 0, 0])
                rounded_box([arm_len, arm_w, arm_t], r=fillet_r, center=true);
}

union(){
    rounded_box([hub_x, hub_y, hub_z], r=fillet_r, center=true);

    arm_x(1);
    arm_x(-1);
    arm_y(1);
    arm_y(-1);

    arm_diag(1,1);
    arm_diag(1,-1);
    arm_diag(-1,1);
    arm_diag(-1,-1);
}