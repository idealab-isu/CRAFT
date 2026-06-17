$fn = 64;

// Board dimensions (requested)
pcb_length = 68.58;
pcb_width  = 53.34;
pcb_thickness = 1.6;

// Small overlap to guarantee connectivity between parts
overlap = 0.2;

// ---------- Helpers ----------
module rounded_rect_prism(l, w, h, r, center=true) {
    // Rounded rectangle via hull of 4 cylinders
    translate(center ? [0,0,0] : [l/2, w/2, h/2])
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(l/2 - r), sy*(w/2 - r), -h/2])
                cylinder(h=h, r=r);
    }
}

module pin_header_row(n=20, pitch=2.54, pin_w=0.64, pin_h=6, base_h=2.5, base_w=2.54) {
    // One connected header: plastic base + pins
    union() {
        // Plastic base
        cube([n*pitch, base_w, base_h], center=true);

        // Pins (connected into base with overlap)
        for (i = [0:n-1]) {
            translate([-(n-1)*pitch/2 + i*pitch, 0, base_h/2 + pin_h/2 - overlap])
                cube([pin_w, pin_w, pin_h], center=true);
        }
    }
}

module mounting_hole(x, y, r=1.6) {
    translate([x, y, 0])
        cylinder(h=pcb_thickness + 2, r=r, center=true);
}

// ---------- Main Model ----------
module dev_board() {
    // Feature sizes (generic dev board look)
    corner_r = 3;

    // Mounting holes (4x) placed by formulas from board size
    edge_margin = 4.0;
    hole_r = 1.6;

    hx = pcb_length/2 - edge_margin;
    hy = pcb_width/2  - edge_margin;

    // Components (generic)
    usb_w = 8.0;
    usb_l = 7.5;
    usb_h = 3.2;

    mcu_l = 14.0;
    mcu_w = 14.0;
    mcu_h = 1.6;

    reg_l = 8.0;
    reg_w = 6.0;
    reg_h = 1.6;

    // Header parameters
    header_n = 20;
    header_pitch = 2.54;
    header_base_h = 2.5;
    header_pin_h  = 6.0;
    header_base_w = 2.54;

    // Place headers near long edges
    header_y_offset = pcb_width/2 - (header_base_w/2 + 2.0);

    union() {
        // PCB with mounting holes cut out
        difference() {
            rounded_rect_prism(pcb_length, pcb_width, pcb_thickness, corner_r, center=true);

            mounting_hole( hx,  hy, hole_r);
            mounting_hole(-hx,  hy, hole_r);
            mounting_hole( hx, -hy, hole_r);
            mounting_hole(-hx, -hy, hole_r);
        }

        // USB connector on one short edge (connected to PCB with overlap)
        translate([pcb_length/2 - usb_l/2 + overlap, 0, pcb_thickness/2 + usb_h/2 - overlap])
            cube([usb_l, usb_w, usb_h], center=true);

        // MCU package centered (connected)
        translate([0, 0, pcb_thickness/2 + mcu_h/2 - overlap])
            cube([mcu_l, mcu_w, mcu_h], center=true);

        // Small regulator near USB (connected)
        translate([pcb_length/2 - usb_l - reg_l/2 - 6, pcb_width/2 - reg_w/2 - 8,
                   pcb_thickness/2 + reg_h/2 - overlap])
            cube([reg_l, reg_w, reg_h], center=true);

        // Two long pin headers (connected)
        translate([0,  header_y_offset, pcb_thickness/2 + header_base_h/2 - overlap])
            pin_header_row(n=header_n, pitch=header_pitch, pin_h=header_pin_h, base_h=header_base_h, base_w=header_base_w);

        translate([0, -header_y_offset, pcb_thickness/2 + header_base_h/2 - overlap])
            pin_header_row(n=header_n, pitch=header_pitch, pin_h=header_pin_h, base_h=header_base_h, base_w=header_base_w);

        // A small button (connected)
        btn_r = 2.2;
        btn_h = 1.8;
        translate([-pcb_length/2 + 14, 0, pcb_thickness/2 + btn_h/2 - overlap])
            cylinder(h=btn_h, r=btn_r, center=true);
    }
}

dev_board();