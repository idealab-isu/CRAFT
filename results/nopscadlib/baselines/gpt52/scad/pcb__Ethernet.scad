$fn=64;

board_x = 33.8;
board_y = 37.5;
board_th = 1.6;

module control_board(x=board_x, y=board_y, th=board_th) {
    translate([-x/2, -y/2, -th/2])
        cube([x, y, th], center=false);
}

control_board();