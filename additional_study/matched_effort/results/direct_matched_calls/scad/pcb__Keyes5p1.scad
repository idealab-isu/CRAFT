$fn = 64;

board_x = 68.58;
board_y = 53.34;
board_th = 1.6;

module dev_board(x=board_x, y=board_y, th=board_th, corner_r=2.0) {
    linear_extrude(height=th)
        offset(r=corner_r)
            square([x - 2*corner_r, y - 2*corner_r], center=true);
}

dev_board();