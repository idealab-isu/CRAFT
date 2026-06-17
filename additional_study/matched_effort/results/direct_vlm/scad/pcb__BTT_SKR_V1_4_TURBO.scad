$fn = 64;

// Mainboard overall size (verified)
board_x = 110.0;
board_y = 85.0;
board_th = 1.6;

// Small overlap to guarantee watertight unions
ov = 0.2;

// --- Feature sizes (approximate mainboard details) ---
corner_r = 3.0;

// Mounting holes (typical 3D printer controller boards)
hole_d = 3.2;
hole_edge_x = 6.0;
hole_edge_y = 6.0;

// Components (kept within board outline)
usb_w = 14.0;   usb_d = 12.0;  usb_h = 7.0;
eth_w = 16.0;   eth_d = 21.0;  eth_h = 13.0;

term_w = 12.0;  term_d = 10.0; term_h = 12.0; // screw terminal blocks
step_w = 15.0;  step_d = 15.0; step_h = 4.0;  // stepper driver modules
cap_r = 4.0;    cap_h = 10.0;                 // electrolytic caps
ic_w = 18.0;    ic_d = 18.0;  ic_h = 2.0;     // main MCU/IC
heats_w = 20.0; heats_d = 20.0; heats_h = 6.0;

header_w = 50.0; header_d = 6.0; header_h = 8.0; // pin header strip

module rounded_board(x, y, th, r) {
    linear_extrude(height=th)
        offset(r=r)
            square([x-2*r, y-2*r], center=true);
}

module mount_holes() {
    for (sx = [-1, 1], sy = [-1, 1]) {
        translate([sx*(board_x/2 - hole_edge_x), sy*(board_y/2 - hole_edge_y), -ov])
            cylinder(d=hole_d, h=board_th + 2*ov, center=false);
    }
}

module component_box(w, d, h, x, y) {
    // Sits on top of PCB and slightly overlaps into it for a single connected solid
    translate([x, y, board_th - ov])
        cube([w, d, h + ov], center=false);
}

module component_cyl(r, h, x, y) {
    translate([x, y, board_th - ov])
        cylinder(r=r, h=h + ov, center=false);
}

color([0.05, 0.45, 0.15])
union() {
    // PCB with mounting holes
    difference() {
        rounded_board(board_x, board_y, board_th, corner_r);
        mount_holes();
    }

    // Edge connectors (placed flush to edges using formulas)
    // USB (left edge)
    component_box(
        usb_w, usb_d, usb_h,
        -board_x/2,                       // flush to left edge
        -usb_d/2                          // slightly toward bottom half
    );

    // Ethernet (left edge, above USB)
    component_box(
        eth_w, eth_d, eth_h,
        -board_x/2,                       // flush to left edge
        board_y/2 - eth_d                 // near top edge
    );

    // Screw terminals (right edge, three blocks)
    for (i = [0:2]) {
        component_box(
            term_w, term_d, term_h,
            board_x/2 - term_w,           // flush to right edge
            -board_y/2 + 10 + i*(term_d + 4)
        );
    }

    // Stepper driver modules (center-right area, 4 modules)
    for (i = [0:3]) {
        component_box(
            step_w, step_d, step_h,
            5 + i*(step_w + 3),
            -5
        );
    }

    // Main IC + heatsink (center)
    component_box(
        ic_w, ic_d, ic_h,
        -ic_w/2,
        -ic_d/2
    );
    component_box(
        heats_w, heats_d, heats_h,
        -heats_w/2,
        -heats_d/2
    );

    // Capacitors (top-right quadrant)
    component_cyl(
        cap_r, cap_h,
        board_x/2 - 18,
        board_y/2 - 18
    );
    component_cyl(
        cap_r, cap_h,
        board_x/2 - 30,
        board_y/2 - 18
    );

    // Long header strip (top edge)
    component_box(
        header_w, header_d, header_h,
        -header_w/2,
        board_y/2 - header_d
    );

    // Small header strip (bottom edge)
    component_box(
        header_w*0.6, header_d, header_h,
        -header_w*0.3,
        -board_y/2
    );
}