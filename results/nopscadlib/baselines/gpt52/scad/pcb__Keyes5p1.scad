$fn=64;

board_len = 68.58;
board_wid = 53.34;
board_thk = 1.6;

module dev_board(l=board_len, w=board_wid, t=board_thk){
    translate([0,0,t/2])
        cube([l,w,t], center=true);
}

dev_board();