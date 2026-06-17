$fn=64;

plate_len = 0.1;
plate_wid = 0.1;
plate_thk = 0.02;

corner_r = 0.02;

hole_d = 0.01;
hole_edge_offset = 0.02;

notch_depth = 0.02;
notch_w1 = 0.03;
notch_w2 = 0.015;
notch_step = 0.01;

text_str = "Sleepy Pi 2";
text_size = 0.018;
text_depth = 0.004;

module rounded_plate(L, W, T, R){
    linear_extrude(height=T, center=true)
        offset(r=R)
            square([L-2*R, W-2*R], center=true);
}

module corner_holes(L, W, T, d, off){
    for (sx=[-1,1], sy=[-1,1])
        translate([sx*(L/2-off), sy*(W/2-off), 0])
            cylinder(h=T*3, d=d, center=true);
}

module side_notch(L, W, T, depth, w1, w2, step){
    union(){
        translate([L/2 - depth/2, 0, 0])
            cube([depth, w1, T*3], center=true);
        translate([L/2 - (depth+step)/2, 0, 0])
            cube([depth+step, w2, T*3], center=true);
    }
}

module face_text(T, size, depth, s){
    union(){
        translate([0, 0, T/2 - depth/2])
            linear_extrude(height=depth, center=true)
                text(s, size=size, halign="center", valign="center", font="Liberation Sans:style=Bold");
        mirror([0,1,0])
            translate([0, 0, -T/2 + depth/2])
                linear_extrude(height=depth, center=true)
                    text(s, size=size, halign="center", valign="center", font="Liberation Sans:style=Bold");
    }
}

difference(){
    union(){
        rounded_plate(plate_len, plate_wid, plate_thk, corner_r);
        face_text(plate_thk, text_size, text_depth, text_str);
    }
    corner_holes(plate_len, plate_wid, plate_thk, hole_d, hole_edge_offset);
    side_notch(plate_len, plate_wid, plate_thk, notch_depth, notch_w1, notch_w2, notch_step);
}