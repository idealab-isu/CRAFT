$fn = 64;

board_x = 68.58;
board_y = 53.34;
board_th = 1.6;

hole_d = 3.3;
hole_r = hole_d/2;

// Assume standard corner mounting holes with 3.0 mm edge offset (common practice)
hole_offset = 3.0;

module pcb() {
    difference() {
        translate([-board_x/2, -board_y/2, -board_th/2])
            cube([board_x, board_y, board_th], center=false);

        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*(board_x/2 - hole_offset), sy*(board_y/2 - hole_offset), 0])
                cylinder(h=board_th + 0.5, r=hole_r, center=true);
        }
    }
}

pcb();