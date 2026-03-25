$fn=96;

arm_len = 40;
arm_w   = 14;
thk     = 4;

chamfer = 1.0;

center_r = 10;
center_thk = 5.2;

module chamfered_bar(len, w, h, c){
    linear_extrude(height=h, center=true)
        offset(delta=-c)
            offset(delta=c)
                square([len, w], center=true);
}

module cross_arms(){
    union(){
        chamfered_bar(2*arm_len, arm_w, thk, chamfer);
        rotate([0,0,90]) chamfered_bar(2*arm_len, arm_w, thk, chamfer);
    }
}

module center_boss(){
    hull(){
        cylinder(h=center_thk, r=center_r, center=true);
        cylinder(h=thk, r=center_r+1.2, center=true);
    }
}

union(){
    cross_arms();
    center_boss();
}