$fn=64;

board_length = 203.2;
board_width  = 49.53;
board_thick  = 1.6;

module control_board(l=board_length, w=board_width, t=board_thick) {
    translate([-l/2, -w/2, -t/2])
        cube([l, w, t], center=false);
}

control_board();