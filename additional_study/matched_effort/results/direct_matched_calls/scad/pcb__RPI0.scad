$fn = 64;

board_x = 65.0;
board_y = 30.0;
board_z = 1.4;

corner_r = 2.0;

module rounded_board(x, y, z, r) {
    r2 = min(r, min(x, y)/2);
    linear_extrude(height = z)
        offset(r = r2)
            square([x - 2*r2, y - 2*r2], center = true);
}

color([0.05, 0.45, 0.15])
    rounded_board(board_x, board_y, board_z, corner_r);