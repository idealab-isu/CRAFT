$fn = 64;

board_x = 67.0;
board_y = 31.0;
board_th = 1.7;

color([0.05, 0.45, 0.12])
translate([-board_x/2, -board_y/2, 0])
cube([board_x, board_y, board_th], center=false);