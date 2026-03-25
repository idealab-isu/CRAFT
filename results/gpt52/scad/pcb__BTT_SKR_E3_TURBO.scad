$fn=64;

module pcb_board(length=102.0, width=90.25, thickness=1.6, corner_r=3.0) {
    linear_extrude(height=thickness, center=true)
        offset(r=corner_r)
            square([length-2*corner_r, width-2*corner_r], center=true);
}

pcb_board();