$fn = 64;

board_x = 68.58;
board_y = 53.34;
board_th = 1.6;

color([0.05, 0.45, 0.18])
translate([-board_x/2, -board_y/2, 0])
cube([board_x, board_y, board_th], center=false);