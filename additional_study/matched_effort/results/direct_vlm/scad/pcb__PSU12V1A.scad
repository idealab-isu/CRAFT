$fn = 64;

// Power supply board overall size (verified by parameters)
board_x = 67.0;
board_y = 31.0;
board_th = 1.7;

eps = 0.2; // small overlap to guarantee one connected solid

module pcb_board() {
    // Centered board for easy, formula-based placement
    color([0.05, 0.45, 0.15])
        cube([board_x, board_y, board_th], center=true);
}

module feature_block(size_xyz, pos_xyz, col=[0.2,0.2,0.2]) {
    // pos_xyz is the CENTER position of the block
    color(col)
        translate(pos_xyz)
            cube(size_xyz, center=true);
}

module feature_cyl(r, h, pos_xyz, col=[0.25,0.25,0.25]) {
    color(col)
        translate(pos_xyz)
            cylinder(r=r, h=h, center=true);
}

union() {
    // PCB
    pcb_board();

    // Common Z placement: sit on top of PCB with slight overlap
    // Any component with height h uses: z = board_th/2 + h/2 - eps
    // This ensures connectivity (no floating parts).

    // AC input terminal block (left edge)
    term_w = 12;
    term_d = 10;
    term_h = 9;
    feature_block(
        [term_w, term_d, term_h],
        [
            -board_x/2 + term_w/2 - eps,
            0,
            board_th/2 + term_h/2 - eps
        ],
        [0.15, 0.15, 0.15]
    );

    // DC output terminal block (right edge)
    out_w = 12;
    out_d = 10;
    out_h = 9;
    feature_block(
        [out_w, out_d, out_h],
        [
            board_x/2 - out_w/2 + eps,
            0,
            board_th/2 + out_h/2 - eps
        ],
        [0.15, 0.15, 0.15]
    );

    // Large transformer/inductor block (center-left)
    mag_w = 18;
    mag_d = 16;
    mag_h = 12;
    feature_block(
        [mag_w, mag_d, mag_h],
        [
            -board_x*0.18,
            0,
            board_th/2 + mag_h/2 - eps
        ],
        [0.10, 0.10, 0.10]
    );

    // Electrolytic capacitor (center-right)
    cap_r = 5.5;
    cap_h = 14;
    feature_cyl(
        cap_r, cap_h,
        [
            board_x*0.18,
            0,
            board_th/2 + cap_h/2 - eps
        ],
        [0.08, 0.08, 0.08]
    );

    // Small heatsink block (upper side, near right)
    hs_w = 10;
    hs_d = 6;
    hs_h = 11;
    feature_block(
        [hs_w, hs_d, hs_h],
        [
            board_x*0.28,
            board_y*0.22,
            board_th/2 + hs_h/2 - eps
        ],
        [0.18, 0.18, 0.18]
    );

    // Controller IC block (lower side, near center)
    ic_w = 8;
    ic_d = 8;
    ic_h = 2.2;
    feature_block(
        [ic_w, ic_d, ic_h],
        [
            0,
            -board_y*0.22,
            board_th/2 + ic_h/2 - eps
        ],
        [0.05, 0.05, 0.05]
    );

    // Two small capacitors (top side)
    sc_r = 2.2;
    sc_h = 5.5;
    for (sx = [-1, 1]) {
        feature_cyl(
            sc_r, sc_h,
            [
                sx * board_x*0.05,
                board_y*0.22,
                board_th/2 + sc_h/2 - eps
            ],
            [0.10, 0.10, 0.10]
        );
    }

    // Mounting hole pads as shallow bosses (still connected solid)
    pad_r = 2.2;
    pad_h = 0.8;
    hole_inset_x = 4.0;
    hole_inset_y = 4.0;
    for (ix = [-1, 1])
    for (iy = [-1, 1]) {
        feature_cyl(
            pad_r, pad_h,
            [
                ix*(board_x/2 - hole_inset_x),
                iy*(board_y/2 - hole_inset_y),
                board_th/2 + pad_h/2 - eps
            ],
            [0.75, 0.65, 0.10]
        );
    }
}