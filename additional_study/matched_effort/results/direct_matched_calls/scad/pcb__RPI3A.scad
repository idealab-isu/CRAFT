$fn = 64;

board_x = 65.0;
board_y = 56.0;
board_th = 1.4;

color([0.05, 0.45, 0.15])
translate([-board_x/2, -board_y/2, 0])
cube([board_x, board_y, board_th], center=false);