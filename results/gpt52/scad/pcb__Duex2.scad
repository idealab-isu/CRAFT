$fn=64;

board_x = 123.0;
board_y = 100.0;
board_t = 1.6;

module control_board(x=board_x, y=board_y, t=board_t){
    translate([-x/2, -y/2, -t/2])
        cube([x, y, t], center=false);
}

control_board();