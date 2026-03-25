$fn=64;

module sbc_board(length=65.0, width=56.0, thickness=1.4) {
    cube([length, width, thickness], center=true);
}

sbc_board();