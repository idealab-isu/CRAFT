$fn=64;

module sbc_board(length=51.0, width=21.0, thickness=1.6) {
    cube([length, width, thickness], center=true);
}

sbc_board();