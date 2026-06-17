$fn=64;

plate_len = 100;
plate_w_wide = 80;
plate_w_narrow = 50;
th = 3;

cut_r = 28;
cut_center_y = plate_len/2 - 18;

slot_w = 4;
slot_l = 22;
slot_gap_x = 14;
slot_gap_y = 12;
slot_center_y = plate_len/2 - 22;

foot_w = 14;
foot_l = 10;
foot_h = 4;
foot_inset_x = 18;
foot_y = -plate_len/2 + 14;

module trapezoid_plate(len, w1, w2, t){
    linear_extrude(height=t, center=true)
        polygon(points=[
            [-w1/2, -len/2],
            [ w1/2, -len/2],
            [ w2/2,  len/2],
            [-w2/2,  len/2]
        ]);
}

module concave_semicircle_cut(r, y0, t){
    translate([0, y0, 0])
        rotate([0,0,180])
            linear_extrude(height=t+0.6, center=true)
                intersection(){
                    circle(r=r);
                    translate([-r, 0]) square([2*r, r], center=false);
                }
}

module slot(x,y,w,l,t){
    translate([x,y,0])
        cube([w,l,t+0.8], center=true);
}

module stencil_text_cut(t){
    txt = "EEZYbot ARM MK2";
    size = 10;
    translate([0, 6, 0])
        linear_extrude(height=t+0.8, center=true)
            text(txt, size=size, halign="center", valign="center", font="Liberation Sans:style=Bold");
}

module text_bridges(t){
    bridge_w = 1.2;
    bridge_l = 3.0;
    y = 6;
    z = 0;
    for (x=[-22,-8,6,20]){
        translate([x,y,z])
            cube([bridge_w, bridge_l, t+0.2], center=true);
    }
}

module feet(){
    for (sx=[-1,1]){
        translate([sx*(plate_w_wide/2 - foot_inset_x), foot_y, -(th/2 + foot_h/2)])
            cube([foot_w, foot_l, foot_h], center=true);
    }
}

difference(){
    union(){
        trapezoid_plate(plate_len, plate_w_wide, plate_w_narrow, th);
        feet();
    }

    concave_semicircle_cut(cut_r, cut_center_y, th);

    for (sx=[-1,1], sy=[-1,1]){
        slot(sx*slot_gap_x/2, slot_center_y + sy*slot_gap_y/2, slot_w, slot_l, th);
    }

    stencil_text_cut(th);
    text_bridges(th);
}