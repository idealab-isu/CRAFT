$fn=64;

module single_board_computer(length=85.0, width=56.0, thickness=1.4) {
    cube([length, width, thickness], center=true);
}

single_board_computer();