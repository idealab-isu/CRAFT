$fn = 64;

// Single-board computer overall size (PCB only)
board_length = 85.0;
board_width  = 56.0;
board_thick  = 1.4;

// Small overlap to guarantee watertight unions/differences
eps = 0.2;

// Rounded corner radius
corner_r = 3.0;

// Mounting holes (approximate 4-hole pattern)
hole_d = 2.8;
hole_edge_x = 3.5;
hole_edge_y = 3.5;

// --- Helpers ---
module rounded_board_2d(L, W, R) {
    hull() {
        translate([R,     R])     circle(r=R);
        translate([L - R, R])     circle(r=R);
        translate([R,     W - R]) circle(r=R);
        translate([L - R, W - R]) circle(r=R);
    }
}

module pcb_only() {
    difference() {
        linear_extrude(height=board_thick)
            rounded_board_2d(board_length, board_width, corner_r);

        // 4 mounting holes (through)
        for (x = [hole_edge_x, board_length - hole_edge_x])
            for (y = [hole_edge_y, board_width - hole_edge_y])
                translate([x, y, -eps])
                    cylinder(h=board_thick + 2*eps, d=hole_d);
    }
}

// --- Main model: ONE connected solid, correct PCB thickness ---
union() {
    pcb_only();
}