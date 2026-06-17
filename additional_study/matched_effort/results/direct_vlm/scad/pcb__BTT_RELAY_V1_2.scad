$fn = 64;

// Mainboard overall size (must match)
board_x  = 80.4;
board_y  = 36.3;
board_th = 1.5;

// Small modeling tolerances / overlaps to ensure ONE connected solid
eps = 0.25;          // overlap amount

// Board corner radius
corner_r = 2.0;

// Mounting holes (4-corner pattern, inset from edges)
hole_inset_x = 4.0;
hole_inset_y = 4.0;
hole_d       = 3.2;

// Helper: rounded rectangle prism (centered)
module rounded_plate(x, y, h, r) {
    linear_extrude(height=h, center=true)
        offset(r=r)
            square([x-2*r, y-2*r], center=true);
}

// Helper: mounting hole positions (centered coordinate system)
module hole_positions() {
    for (sx = [-1, 1], sy = [-1, 1])
        translate([sx*(board_x/2 - hole_inset_x), sy*(board_y/2 - hole_inset_y), 0])
            children();
}

difference() {
    // ONE connected solid: PCB + components unioned together
    union() {
        // PCB (flat 1.5mm)
        translate([0, 0, board_th/2])
            rounded_plate(board_x, board_y, board_th, corner_r);

        // --- Top-side components (all overlap into PCB by eps) ---
        z_top = board_th + eps;

        // Large MCU/driver chip
        chip1_x = 18;
        chip1_y = 18;
        chip1_h = 2.0;
        translate([0, 0, z_top + chip1_h/2 - eps])
            cube([chip1_x, chip1_y, chip1_h], center=true);

        // Smaller chip
        chip2_x = 14;
        chip2_y = 10;
        chip2_h = 1.6;
        translate([-(board_x*0.18), (board_y*0.12), z_top + chip2_h/2 - eps])
            cube([chip2_x, chip2_y, chip2_h], center=true);

        // USB connector on +Y edge (protrudes outward, overlaps into PCB)
        usb_x = 12;
        usb_y = 14;
        usb_h = 6.0;
        translate([0,
                   board_y/2 + usb_y/2 - eps,
                   z_top + usb_h/2 - eps])
            cube([usb_x, usb_y, usb_h], center=true);

        // Screw terminal block on -Y edge
        term_x = 22;
        term_y = 12;
        term_h = 8.0;
        translate([board_x*0.18,
                   -(board_y/2 + term_y/2 - eps),
                   z_top + term_h/2 - eps])
            cube([term_x, term_y, term_h], center=true);

        // Pin header along +Y long edge (sits on board, does not extend past edge)
        pin_x = 40;
        pin_y = 6;
        pin_h = 5.0;
        translate([-(board_x*0.05),
                   board_y/2 - pin_y/2 + eps,
                   z_top + pin_h/2 - eps])
            cube([pin_x, pin_y, pin_h], center=true);

        // Capacitors (cylinders)
        cap_r1 = 3.2;
        cap_h1 = 7.0;
        translate([board_x*0.30, board_y*0.05, z_top + cap_h1/2 - eps])
            cylinder(r=cap_r1, h=cap_h1, center=true);

        cap_r2 = cap_r1*0.9;
        cap_h2 = cap_h1-1;
        translate([board_x*0.34, -board_y*0.10, z_top + cap_h2/2 - eps])
            cylinder(r=cap_r2, h=cap_h2, center=true);

        // --- Bottom-side components (all overlap into PCB by eps) ---
        z_bot = -eps; // slightly into PCB from below

        // Bottom IC / driver
        bchip_x = 16;
        bchip_y = 12;
        bchip_h = 1.8;
        translate([board_x*0.10, -board_y*0.05, -(bchip_h/2) + z_bot])
            cube([bchip_x, bchip_y, bchip_h], center=true);

        // Bottom connector housing (e.g., SD/aux) near +X edge
        bconn_x = 18;
        bconn_y = 10;
        bconn_h = 3.0;
        translate([board_x/2 - bconn_x/2 + eps,
                   board_y*0.10,
                   -(bconn_h/2) + z_bot])
            cube([bconn_x, bconn_y, bconn_h], center=true);
    }

    // Mounting holes through PCB only (do not cut components)
    hole_positions()
        translate([0, 0, board_th/2])
            cylinder(d=hole_d, h=board_th + 2*eps, center=true);
}