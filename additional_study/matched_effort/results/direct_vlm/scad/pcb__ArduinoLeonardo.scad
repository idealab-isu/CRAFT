$fn = 32;

// Microcontroller development board overall size (mm)
board_x = 68.58;
board_y = 53.34;
board_th = 1.6;

// Small overlap to guarantee watertight unions
eps = 0.05;

// ---------- Helpers ----------
module rounded_rect_prism(x, y, z, r) {
    // Fast rounded rectangle via 2D offset + linear_extrude
    linear_extrude(height=z, center=true, convexity=5)
        offset(r=r)
            square([x - 2*r, y - 2*r], center=true);
}

module pin_header_row(n=20, pitch=2.54, pin=1.0, h=6, base_h=2.2, base_w=5.0) {
    union() {
        // plastic base
        translate([0, 0, base_h/2])
            cube([ (n-1)*pitch + base_w, base_w, base_h ], center=true);

        // pins
        for (i = [0:n-1]) {
            x = -((n-1)*pitch)/2 + i*pitch;
            translate([x, 0, base_h + h/2 - eps])
                cube([pin, pin, h], center=true);
        }
    }
}

module usb_micro_port(w=7.6, d=6.0, h=2.6, shell=0.6) {
    // Simple USB micro-like shell block with a shallow recess
    difference() {
        translate([0, 0, h/2])
            cube([w, d, h], center=true);
        translate([0, d*0.05, h*0.55])
            cube([w - 2*shell, d - 2*shell, h], center=true);
    }
}

module barrel_jack(w=14, d=9, h=11) {
    translate([0, 0, h/2])
        cube([w, d, h], center=true);
}

module ic_qfp(body=14, h=1.6, lead=1.2, lead_w=0.6) {
    union() {
        translate([0, 0, h/2])
            cube([body, body, h], center=true);

        for (side = [0:3]) {
            rotate([0, 0, side*90])
                translate([0, body/2 + lead/2 - eps, h/2])
                    cube([body*0.85, lead, lead_w], center=true);
        }
    }
}

module smd_chip(x=6, y=6, h=1.2) {
    translate([0, 0, h/2])
        cube([x, y, h], center=true);
}

module mounting_hole_pattern(hole_d=3.2, inset=3.5) {
    for (sx = [-1, 1], sy = [-1, 1]) {
        translate([sx*(board_x/2 - inset), sy*(board_y/2 - inset), 0])
            cylinder(d=hole_d, h=board_th + 2, center=true);
    }
}

// ---------- Board Model ----------
module dev_board() {
    corner_r = 3.0;

    z_top = board_th/2;

    header_n = 20;
    header_pitch = 2.54;
    header_base_w = 5.0;
    header_base_h = 2.2;
    header_pin_h = 6.0;

    header_y_offset = board_y/2 - (header_base_w/2) - 2.0;

    usb_w = 7.6; usb_d = 6.0; usb_h = 2.6;
    jack_w = 14; jack_d = 9; jack_h = 11;

    conn_edge_inset = 2.0;
    usb_x  = -board_x/2 + conn_edge_inset + usb_d/2;
    jack_x = -board_x/2 + conn_edge_inset + jack_d/2;

    usb_y = 0;
    jack_y = board_y*0.28;

    mcu_x = board_x*0.05;
    mcu_y = 0;

    sec_x = -board_x*0.18;
    sec_y = -board_y*0.18;

    reg_x = -board_x*0.10;
    reg_y = board_y*0.22;

    union() {
        // PCB with mounting holes (single difference)
        difference() {
            color([0.05, 0.45, 0.18])
                rounded_rect_prism(board_x, board_y, board_th, corner_r);
            mounting_hole_pattern(3.2, 3.5);
        }

        // Headers
        color([0.1, 0.1, 0.1])
        translate([0,  header_y_offset, z_top - eps])
            pin_header_row(n=header_n, pitch=header_pitch, pin=1.0, h=header_pin_h, base_h=header_base_h, base_w=header_base_w);

        color([0.1, 0.1, 0.1])
        translate([0, -header_y_offset, z_top - eps])
            pin_header_row(n=header_n, pitch=header_pitch, pin=1.0, h=header_pin_h, base_h=header_base_h, base_w=header_base_w);

        // USB port
        color([0.75, 0.75, 0.78])
        translate([usb_x, usb_y, z_top - eps])
            rotate([0, 0, 90])
                usb_micro_port(w=usb_w, d=usb_d, h=usb_h, shell=0.6);

        // Barrel jack
        color([0.05, 0.05, 0.05])
        translate([jack_x, jack_y, z_top - eps])
            rotate([0, 0, 90])
                barrel_jack(w=jack_w, d=jack_d, h=jack_h);

        // MCU
        color([0.15, 0.15, 0.15])
        translate([mcu_x, mcu_y, z_top - eps])
            ic_qfp(body=14, h=1.6, lead=1.2, lead_w=0.6);

        // Secondary chip
        color([0.18, 0.18, 0.18])
        translate([sec_x, sec_y, z_top - eps])
            smd_chip(10, 8, 1.4);

        // Regulator / power block
        color([0.2, 0.2, 0.2])
        translate([reg_x, reg_y, z_top - eps])
            smd_chip(8, 6, 1.6);

        // Small passives
        color([0.85, 0.82, 0.75])
        for (p = [
            [board_x*0.22,  board_y*0.18],
            [board_x*0.26,  board_y*0.10],
            [board_x*0.18, -board_y*0.12],
            [board_x*0.10, -board_y*0.22],
            [-board_x*0.02, board_y*0.30]
        ]) {
            translate([p[0], p[1], z_top - eps])
                smd_chip(3.2, 1.6, 1.0);
        }
    }
}

dev_board();