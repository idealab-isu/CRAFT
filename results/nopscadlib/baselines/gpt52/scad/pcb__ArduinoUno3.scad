$fn=64;

board_x = 68.58;
board_y = 53.34;
board_t = 1.6;

module dev_board(x, y, t) {
    translate([-x/2, -y/2, -t/2])
        cube([x, y, t], center=false);
}

dev_board(board_x, board_y, board_t);