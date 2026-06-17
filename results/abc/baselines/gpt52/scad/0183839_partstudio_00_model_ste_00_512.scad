$fn=96;

L = 100;
W = 30;
H = 20;

ch = 4;

bore_flat = 12;
bore_r = bore_flat/(2*cos(180/8));

slot_len = 80;
slot_w = 6;
slot_depth = 2;
slot_y = 0;

pad_size = 6;
pad_depth = 1.5;
pad_margin_x = 10;
pad_margin_y = 6;

module chamfered_block(l, w, h, c){
    difference(){
        cube([l,w,h], center=true);
        for (sx=[-1,1], sy=[-1,1]){
            translate([sx*(l/2 - c/2), sy*(w/2 - c/2), 0])
                rotate([0,0,45])
                    cube([c*sqrt(2), c*sqrt(2), h+0.2], center=true);
        }
    }
}

module oct_bore(h, r){
    rotate([0,90,0])
        cylinder(h=h, r=r, center=true, $fn=8);
}

module top_features(){
    union(){
        translate([0, slot_y, H/2 - slot_depth/2 + 0.001])
            cube([slot_len, slot_w, slot_depth], center=true);

        for (sx=[-1,1], sy=[-1,1]){
            translate([sx*(L/2 - pad_margin_x - pad_size/2),
                       sy*(W/2 - pad_margin_y - pad_size/2),
                       H/2 - pad_depth/2 + 0.001])
                cube([pad_size, pad_size, pad_depth], center=true);
        }
    }
}

difference(){
    chamfered_block(L,W,H,ch);
    oct_bore(W+2, bore_r);
    top_features();
}