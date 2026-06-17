$fn = 64;

// Mainboard overall dimensions (mm)
board_x  = 100.75;
board_y  = 70.25;
board_th = 1.6;

// Small overlap to guarantee watertight unions
ov = 0.2;

// ---------- Helper modules ----------
module pcb_plate(x, y, th, corner_r=3) {
    // Rounded-rectangle PCB
    linear_extrude(height=th)
        offset(r=corner_r)
            square([x-2*corner_r, y-2*corner_r], center=true);
}

module hole_at(x, y, r, h) {
    translate([x, y, -ov]) cylinder(r=r, h=h + 2*ov, center=false);
}

module box_on_top(cx, cy, sx, sy, sz, z0) {
    // z0 is the board top surface (board_th)
    translate([cx, cy, z0 + sz/2 - ov])
        cube([sx, sy, sz], center=true);
}

module cyl_on_top(cx, cy, r, h, z0) {
    translate([cx, cy, z0 + h/2 - ov])
        cylinder(r=r, h=h, center=true);
}

// ---------- Feature sizing (generic mainboard look) ----------
mount_r = 1.7;                 // ~M3 clearance radius
mount_inset = 4.0;             // distance from edges to hole centers

// Connectors/components (generic, but dimension-driven)
usb_w = 14; usb_d = 16; usb_h = 8;
power_w = 10; power_d = 12; power_h = 10;
stepper_w = 10; stepper_d = 14; stepper_h = 9;
header_w = 50; header_d = 6; header_h = 6;
heatsink_r = 6; heatsink_h = 6;

// ---------- Build ----------
color([0.05, 0.45, 0.12])
union() {
    // PCB with mounting holes removed (still one connected solid)
    difference() {
        pcb_plate(board_x, board_y, board_th, corner_r=3);

        // 4 mounting holes (formulas from board dimensions)
        hx = board_x/2 - mount_inset;
        hy = board_y/2 - mount_inset;
        hole_at( hx,  hy, mount_r, board_th);
        hole_at(-hx,  hy, mount_r, board_th);
        hole_at( hx, -hy, mount_r, board_th);
        hole_at(-hx, -hy, mount_r, board_th);
    }

    // --- Top-side components (all connected via overlap into PCB) ---
    ztop = board_th;

    // USB connector on right edge
    box_on_top(
        board_x/2 - usb_d/2,          // center sits at edge
        0,
        usb_d, usb_w, usb_h,
        ztop
    );

    // Power terminal on left edge (upper half)
    box_on_top(
        -board_x/2 + power_d/2,
        board_y/4,
        power_d, power_w, power_h,
        ztop
    );

    // Stepper driver connectors along bottom edge (3x)
    for (i = [-1, 0, 1]) {
        box_on_top(
            i * (board_x/4),
            -board_y/2 + stepper_d/2,
            stepper_w, stepper_d, stepper_h,
            ztop
        );
    }

    // Long pin header along top edge
    box_on_top(
        0,
        board_y/2 - header_d/2,
        header_w, header_d, header_h,
        ztop
    );

    // A couple of "heatsinks"/ICs near center
    cyl_on_top(-board_x/8, 0, heatsink_r, heatsink_h, ztop);
    cyl_on_top( board_x/8, 0, heatsink_r, heatsink_h, ztop);

    // Small capacitor-like cylinders near power input
    cyl_on_top(
        -board_x/2 + power_d + 6,
        board_y/4 + power_w/2 + 6,
        3, 8,
        ztop
    );
    cyl_on_top(
        -board_x/2 + power_d + 14,
        board_y/4 + power_w/2 + 6,
        3, 8,
        ztop
    );
}