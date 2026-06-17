$fn=64;

module pcb_board(len=67.0, wid=31.0, th=1.7, corner_r=2.0) {
    corner_r2 = min(corner_r, min(len, wid)/2);
    linear_extrude(height=th, center=true)
        offset(r=corner_r2)
            square([len-2*corner_r2, wid-2*corner_r2], center=true);
}

pcb_board();