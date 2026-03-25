$fn=64;

L = 1.4;
W = 0.9;
H = 0.3;

mid_len = 0.92;
cap_len = (L - mid_len)/2;

r_mid = 0.11;
r_fin = 0.135;

fin_count = 14;
fin_th = 0.018;

tab_count = 8;
tab_w = 0.06;
tab_t = 0.03;
tab_h = 0.06;

nub_r = 0.035;
nub_len = 0.06;

module fin_ring(zpos){
    translate([0,0,zpos])
        cylinder(h=fin_th, r=r_fin, center=true);
}

module ribbed_mid(){
    union(){
        cylinder(h=mid_len, r=r_mid, center=true);
        for(i=[0:fin_count-1]){
            z = -mid_len/2 + (i+0.5)*mid_len/fin_count;
            fin_ring(z);
        }
    }
}

module end_cap(zc, flip=1){
    translate([0,0,zc])
    union(){
        cylinder(h=cap_len, r=0.16, center=true, $fn=6);
        translate([0,0,flip*(cap_len*0.15)])
            cylinder(h=cap_len*0.7, r=0.145, center=true, $fn=6);
    }
}

module radial_tab(zpos, ang){
    translate([0,0,zpos])
    rotate([0,0,ang])
    translate([r_fin + tab_t/2, 0, 0])
        cube([tab_t, tab_w, tab_h], center=true);
}

module tabs_along(){
    union(){
        for(i=[0:tab_count-1]){
            z = -mid_len/2 + (i+0.5)*mid_len/tab_count;
            radial_tab(z, 0);
            radial_tab(z, 180);
        }
    }
}

module side_nub(){
    zpos = L/2 - cap_len*0.65;
    translate([0,0,zpos])
    translate([r_fin + nub_len/2, 0, 0])
    rotate([0,90,0])
        cylinder(h=nub_len, r=nub_r, center=true);
}

module part(){
    union(){
        ribbed_mid();
        end_cap(-L/2 + cap_len/2, flip=-1);
        end_cap( L/2 - cap_len/2, flip= 1);
        tabs_along();
        side_nub();
    }
}

scale([W/(2*(r_fin + tab_t)), H/(2*(r_fin + tab_t)), 1])
    part();