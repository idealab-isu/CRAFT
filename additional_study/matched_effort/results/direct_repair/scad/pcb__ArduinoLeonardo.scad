$fn = 64;

board_len = 68.58;
board_wid = 53.34;
board_thk = 1.6;

corner_r = 3.0;

module rounded_rect_2d(l, w, r) {
    r2 = min(r, min(l, w)/2);
    hull() {
        translate([ r2,      r2     ]) circle(r=r2);
        translate([ l - r2,  r2     ]) circle(r=r2);
        translate([ r2,      w - r2 ]) circle(r=r2);
        translate([ l - r2,  w - r2 ]) circle(r=r2);
    }
}

linear_extrude(height=board_thk)
    rounded_rect_2d(board_len, board_wid, corner_r);