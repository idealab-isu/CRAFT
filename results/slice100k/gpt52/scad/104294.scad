$fn=96;

W = 24.4;
L = 99.3;
T = 2.0;

tab_len = 18.0;
body_len = L - tab_len;

tip_len = 12.0;

slot_pitch = 6.0;
slot_w = 3.0;
slot_len = 12.0;
slot_margin_side = 2.2;
slot_margin_end = 6.0;

hole_d = 3.2;
hole_x = 7.0;
hole_y_off = 6.0;

scallop_r = 5.2;
scallop_teeth = 10;
scallop_amp = 1.2;

module rounded_rect_2d(w,l,r){
    hull(){
        translate([ w/2-r,  l/2-r]) circle(r=r);
        translate([-w/2+r,  l/2-r]) circle(r=r);
        translate([ w/2-r, -l/2+r]) circle(r=r);
        translate([-w/2+r, -l/2+r]) circle(r=r);
    }
}

module base_plate(){
    union(){
        translate([0, -L/2 + tab_len/2, 0])
            linear_extrude(height=T)
                rounded_rect_2d(W, tab_len, 2.0);

        translate([0, -L/2 + tab_len + body_len/2, 0])
            linear_extrude(height=T)
                rounded_rect_2d(W, body_len, 1.2);

        translate([0, L/2 - tip_len/2, 0])
            linear_extrude(height=T)
                polygon(points=[
                    [-W/2, -tip_len/2],
                    [ W/2, -tip_len/2],
                    [ 0,   tip_len/2]
                ]);
    }
}

module slot_cutouts(){
    y_start = -L/2 + tab_len + slot_margin_end;
    y_end   =  L/2 - tip_len - slot_margin_end;
    n = floor((y_end - y_start)/slot_pitch) + 1;

    for(i=[0:n-1]){
        y = y_start + i*slot_pitch;
        translate([0, y, -0.1])
            cube([W - 2*slot_margin_side, slot_len, T+0.2], center=true);
    }
}

module scalloped_cutout_2d(r, teeth, amp){
    union(){
        circle(r=r);
        for(i=[0:teeth-1]){
            a = 360*i/teeth;
            rotate(a) translate([r,0]) circle(r=amp);
        }
    }
}

module mounting_features_cut(){
    y_tab_center = -L/2 + tab_len/2;

    translate([0, y_tab_center, -0.1])
        linear_extrude(height=T+0.2)
            scalloped_cutout_2d(scallop_r, scallop_teeth, scallop_amp);

    for(s=[-1,1]){
        translate([s*hole_x, y_tab_center - hole_y_off, -0.1])
            cylinder(d=hole_d, h=T+0.2);
        translate([s*hole_x, y_tab_center + hole_y_off, -0.1])
            cylinder(d=hole_d, h=T+0.2);
    }
}

difference(){
    base_plate();
    slot_cutouts();
    mounting_features_cut();
}