$fn = 64;

// Control board overall size (must match)
board_x = 123.0;
board_y = 100.0;
board_th = 1.6;

// Visual feature sizes (approximate, but all connected)
corner_r = 3.0;

// Mounting holes (typical M3 clearance)
hole_d = 3.2;
hole_edge_x = 6.0;
hole_edge_y = 6.0;

// Component heights
soldermask_bump = 0.25;   // slight top relief so renders aren't "flat"
connector_h = 12.0;
ic_h = 3.0;
cap_h = 10.0;
terminal_h = 14.0;

// Small overlap to guarantee connectivity
ov = 0.4;

// Helpers
module rounded_plate(x, y, z, r) {
    // Rounded rectangle prism using hull of corner cylinders
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(x/2 - r), sy*(y/2 - r), 0])
                cylinder(r=r, h=z, center=true);
    }
}

module mount_holes() {
    for (sx = [-1, 1], sy = [-1, 1])
        translate([sx*(board_x/2 - hole_edge_x), sy*(board_y/2 - hole_edge_y), 0])
            cylinder(d=hole_d, h=board_th + 2, center=true);
}

module usb_connector() {
    // USB-B like block on one edge
    usb_w = 14.0;
    usb_d = 16.0;
    usb_h = connector_h;

    translate([0, board_y/2 - usb_d/2 + ov, board_th/2 + usb_h/2 - ov])
        cube([usb_w, usb_d, usb_h], center=true);
}

module power_terminal() {
    // Screw terminal block near an edge
    term_w = 20.0;
    term_d = 12.0;
    term_h = terminal_h;

    translate([board_x/2 - term_w/2 + ov, -board_y/2 + term_d/2 - ov, board_th/2 + term_h/2 - ov])
        cube([term_w, term_d, term_h], center=true);
}

module pin_headers() {
    // Two long header strips along one side
    hdr_w = 2.6;
    hdr_h = 8.0;
    hdr_d1 = 60.0;
    hdr_d2 = 40.0;

    x_pos = -board_x/2 + hdr_w/2 - ov;

    translate([x_pos, 0, board_th/2 + hdr_h/2 - ov])
        cube([hdr_w, hdr_d1, hdr_h], center=true);

    translate([x_pos, board_y/2 - hdr_d2/2 - 10.0, board_th/2 + hdr_h/2 - ov])
        cube([hdr_w, hdr_d2, hdr_h], center=true);
}

module stepper_drivers() {
    // 4 driver modules as raised blocks
    drv_x = 18.0;
    drv_y = 22.0;
    drv_h = 10.0;

    spacing = 24.0;
    y0 = 10.0;

    for (i = [0:3]) {
        translate([-board_x/2 + 30.0 + i*spacing, y0, board_th/2 + drv_h/2 - ov])
            cube([drv_x, drv_y, drv_h], center=true);
    }
}

module main_ic() {
    // Central MCU/IC
    ic_x = 18.0;
    ic_y = 18.0;
    translate([0, -5.0, board_th/2 + ic_h/2 - ov])
        cube([ic_x, ic_y, ic_h], center=true);
}

module capacitors() {
    // Two electrolytic caps as cylinders
    cap_r = 4.0;
    cap_hh = cap_h;

    for (p = [[-35, -25], [-20, -25]]) {
        translate([p[0], p[1], board_th/2 + cap_hh/2 - ov])
            cylinder(r=cap_r, h=cap_hh, center=true);
    }
}

module top_relief() {
    // Slight raised "soldermask" islands to avoid blank/flat look
    island_h = soldermask_bump;
    island_z = board_th/2 + island_h/2 - ov;

    translate([0, 0, island_z])
        cube([board_x - 10, board_y - 10, island_h], center=true);

    translate([0, 0, island_z])
        cube([board_x - 30, board_y - 30, island_h], center=true);
}

// Build: one connected solid (holes are subtracted but do not disconnect the solid)
difference() {
    union() {
        // Board base (centered for easier feature placement)
        color([0.05, 0.45, 0.12])
            rounded_plate(board_x, board_y, board_th, corner_r);

        // Connected top features
        color([0.15, 0.15, 0.15]) usb_connector();
        color([0.10, 0.10, 0.10]) power_terminal();
        color([0.20, 0.20, 0.20]) pin_headers();
        color([0.25, 0.25, 0.25]) stepper_drivers();
        color([0.12, 0.12, 0.12]) main_ic();
        color([0.18, 0.18, 0.18]) capacitors();

        // Subtle relief on top surface
        color([0.06, 0.50, 0.14]) top_relief();
    }

    // Mounting holes through the PCB
    mount_holes();
}