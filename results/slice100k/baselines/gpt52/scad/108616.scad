$fn=64;

th = 4.0;

L = 73.0;
W = 20.0;

head_len = 28.0;
head_w = 20.0;
head_r = 6.0;

neck_len = 10.0;
handle_len = L - head_len - neck_len;

handle_w = 10.0;

window_len = 16.0;
window_w = 10.0;
window_r = 2.0;

hole_d = 3.0;
hole_offset_x = 6.0;
hole_y = 0.0;

module rounded_rect_2d(len, wid, r){
    r2 = min(r, min(len, wid)/2);
    hull(){
        translate([ len/2 - r2,  wid/2 - r2]) circle(r=r2);
        translate([-len/2 + r2,  wid/2 - r2]) circle(r=r2);
        translate([ len/2 - r2, -wid/2 + r2]) circle(r=r2);
        translate([-len/2 + r2, -wid/2 + r2]) circle(r=r2);
    }
}

module plate_outline_2d(){
    union(){
        translate([-(L/2) + head_len/2, 0])
            rounded_rect_2d(head_len, head_w, head_r);

        translate([ (L/2) - handle_len/2, 0])
            square([handle_len, handle_w], center=true);

        x0 = -(L/2) + head_len;
        x1 = x0 + neck_len;
        polygon(points=[
            [x0,  head_w/2],
            [x0, -head_w/2],
            [x1, -handle_w/2],
            [x1,  handle_w/2]
        ]);
    }
}

module window_cut_2d(){
    translate([-(L/2) + head_len/2, 0])
        rounded_rect_2d(window_len, window_w, window_r);
}

module holes_cut_2d(){
    cx = -(L/2) + head_len/2;
    translate([cx - hole_offset_x, hole_y]) circle(d=hole_d);
    translate([cx + hole_offset_x, hole_y]) circle(d=hole_d);
}

difference(){
    linear_extrude(height=th, center=true)
        plate_outline_2d();

    linear_extrude(height=th+0.4, center=true)
        window_cut_2d();

    linear_extrude(height=th+0.4, center=true)
        holes_cut_2d();
}