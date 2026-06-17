$fn=64;

L = 85.1;
W = 22.5;
H = 3.2;

ch = 4.0;

pr_w = 10.0;
pr_t = 6.0;
pr_h = 7.2;

step_len = 2.2;
step_drop = 2.0;

pr1_x = -18.0;
pr2_x = 18.0;

module chamfered_bar(len, wid, ht, chamf){
    difference(){
        translate([0,0,ht/2]) cube([len,wid,ht], center=true);
        for (sx=[-1,1], sy=[-1,1]){
            translate([sx*(len/2 - chamf/2), sy*(wid/2 - chamf/2), ht/2])
                rotate([0,0,45]) cube([chamf, chamf, ht+0.4], center=true);
        }
    }
}

module prong(pr_len, pr_wid, pr_ht, stepL, stepDrop){
    union(){
        translate([0,0,pr_ht/2]) cube([pr_len, pr_wid, pr_ht], center=true);
        translate([pr_len/2 - stepL/2, 0, (pr_ht - stepDrop)/2])
            cube([stepL, pr_wid, pr_ht - stepDrop], center=true);
    }
}

module bracket(){
    union(){
        chamfered_bar(L,W,H,ch);
        translate([pr1_x, 0, H]) prong(pr_t, pr_w, pr_h, step_len, step_drop);
        translate([pr2_x, 0, H]) prong(pr_t, pr_w, pr_h, step_len, step_drop);
    }
}

bracket();