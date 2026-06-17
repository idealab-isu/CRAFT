$fn = 64;

board_x = 20.0;
board_y = 14.0;
board_z = 1.6;

color([0.05, 0.45, 0.12])
translate([-board_x/2, -board_y/2, 0])
cube([board_x, board_y, board_z], center=false);