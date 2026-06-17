$fn = 64;

// 3D printer control board (approximate features)
// Overall: 123.0mm x 100.0mm x 1.6mm
board_x = 123.0;
board_y = 100.0;
board_th = 1.6;

// Small overlap to guarantee watertight unions
ov = 0.2;

// ---------- Helpers ----------
module pcb_plate(x, y, th, corner_r=3) {
    // Rounded-rectangle PCB as a single solid
    linear_extrude(height=th)
        offset(r=corner_r)
            square([x-2*corner_r, y-2*corner_r], center=true);
}

module box_on_top(size=[10,10,10], z0=0) {
    // Places a box so its bottom sits at z0, with slight overlap into the PCB
    translate([0,0, z0 + size[2]/2 - ov])
        cube(size, center=true);
}

module cyl_on_top(r=5, h=5, z0=0) {
    translate([0,0, z0 + h/2 - ov])
        cylinder(r=r, h=h, center=true);
}

module mounting_hole(x, y, r=1.6) {
    translate([x, y, -ov])
        cylinder(r=r, h=board_th + 2*ov, center=false);
}

// ---------- Model ----------
difference() {
    union() {
        // PCB
        color([0.05, 0.45, 0.12])
            pcb_plate(board_x, board_y, board_th, corner_r=3);

        // Components/connectors (all connected to PCB top surface)
        // USB-B style connector on left edge
        usb_w = 16; usb_d = 14; usb_h = 11;
        translate([-(board_x/2 - usb_d/2), 0, 0])
            box_on_top([usb_d, usb_w, usb_h], z0=board_th);

        // Power terminal block on right edge
        pwr_d = 12; pwr_w = 18; pwr_h = 12;
        translate([(board_x/2 - pwr_d/2), board_y*0.25, 0])
            box_on_top([pwr_d, pwr_w, pwr_h], z0=board_th);

        // Stepper driver headers row (top edge)
        hdr_d = 6; hdr_w = 60; hdr_h = 8;
        translate([0, (board_y/2 - hdr_d/2), 0])
            box_on_top([hdr_w, hdr_d, hdr_h], z0=board_th);

        // Endstop/IO headers (bottom edge)
        io_d = 6; io_w = 50; io_h = 7;
        translate([board_x*0.10, -(board_y/2 - io_d/2), 0])
            box_on_top([io_w, io_d, io_h], z0=board_th);

        // Main MCU/processor package (center)
        mcu = [22, 22, 3];
        translate([-board_x*0.05, -board_y*0.05, 0])
            box_on_top(mcu, z0=board_th);

        // Heatsink block (near center-right)
        hs = [18, 18, 8];
        translate([board_x*0.18, 0, 0])
            box_on_top(hs, z0=board_th);

        // Capacitors (cylinders) near power area
        cap_r = 4; cap_h = 10;
        cap_dx = 2*cap_r + 3;
        for (i = [0:2]) {
            translate([(board_x/2 - pwr_d) - cap_r - 6, board_y*0.25 + (i-1)*cap_dx, 0])
                cyl_on_top(r=cap_r, h=cap_h, z0=board_th);
        }

        // Small ICs (scattered)
        ic1 = [10, 8, 2];
        ic2 = [12, 10, 2.2];
        translate([-board_x*0.25, board_y*0.18, 0]) box_on_top(ic1, z0=board_th);
        translate([ board_x*0.05, board_y*0.20, 0]) box_on_top(ic2, z0=board_th);
        translate([ board_x*0.22, -board_y*0.18, 0]) box_on_top(ic1, z0=board_th);
    }

    // Mounting holes (through PCB)
    hole_margin_x = 6.0;
    hole_margin_y = 6.0;
    hx = board_x/2 - hole_margin_x;
    hy = board_y/2 - hole_margin_y;

    mounting_hole( hx,  hy, r=1.7);
    mounting_hole(-hx,  hy, r=1.7);
    mounting_hole( hx, -hy, r=1.7);
    mounting_hole(-hx, -hy, r=1.7);
}