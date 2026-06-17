$fn=64;

module mounting_hole(d=3.2, t=3) {
    cylinder(d=d, h=t, center=true);
}

module pcb_board(l=78.0, w=47.0, t=1.6, corner_r=2.5) {
    linear_extrude(height=t, center=true)
        offset(r=corner_r)
            square([l-2*corner_r, w-2*corner_r], center=true);
}

module dc_dc_module() {
    board_l = 78.0;
    board_w = 47.0;
    board_t = 1.6;

    hole_d = 3.2;
    hole_inset_x = 3.5;
    hole_inset_y = 3.5;

    hole_x = board_l/2 - hole_inset_x;
    hole_y = board_w/2 - hole_inset_y;

    difference() {
        pcb_board(board_l, board_w, board_t, corner_r=2.5);

        for (sx=[-1,1], sy=[-1,1])
            translate([sx*hole_x, sy*hole_y, 0])
                mounting_hole(d=hole_d, t=board_t+2);
    }
}

dc_dc_module();