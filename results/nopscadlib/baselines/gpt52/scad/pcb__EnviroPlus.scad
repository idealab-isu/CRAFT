$fn=64;

board_len = 65.0;
board_wid = 30.6;
board_thk = 1.6;

module sensor_board(l=board_len, w=board_wid, t=board_thk){
    translate([0,0,t/2])
        cube([l,w,t], center=true);
}

sensor_board();