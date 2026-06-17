$fn = 48;

// Target board dimensions (mm)
pcb_L = 68.58;
pcb_W = 53.34;
pcb_T = 1.6;

// Geometry controls
corner_r = 3;          // rounded corner radius
hole_r   = 1.6;        // mounting hole radius
hole_edge_clear = 3.2; // hole center distance from each edge

// Small overlap to guarantee watertight unions
ov = 0.25;

// ---------- Helpers ----------
module rounded_rect_2d(L, W, r) {
    // 2D rounded rectangle centered at origin
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(L/2 - r), sy*(W/2 - r)]) circle(r=r);
    }
}

module pcb_base() {
    // PCB with rounded corners and through mounting holes
    difference() {
        linear_extrude(height=pcb_T, center=true)
            rounded_rect_2d(pcb_L, pcb_W, corner_r);

        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*(pcb_L/2 - hole_edge_clear),
                       sy*(pcb_W/2 - hole_edge_clear),
                       0])
                cylinder(r=hole_r, h=pcb_T + 2*ov, center=true);
        }
    }
}

// ---------- Features (all CONNECTED to PCB) ----------
module header_strip(len, pins=20, pin_pitch=2.54, body_w=5.0, body_h=8.0, pin_r=0.55, pin_h=3.0) {
    // Black plastic body + pins; placed with its bottom slightly embedded into PCB
    union() {
        // plastic body
        translate([0, 0, pcb_T/2 + body_h/2 - ov])
            cube([len, body_w, body_h], center=true);

        // pins (downward)
        for (i = [0:pins-1]) {
            x = -len/2 + (i + 0.5) * (len/pins);
            translate([x, 0, pcb_T/2 - pin_h/2 + ov])
                cylinder(r=pin_r, h=pin_h, center=true);
        }
    }
}

module usb_micro_port(port_L=7.5, port_W=7.0, port_H=3.0, shell_L=6.0) {
    // Simple USB connector block protruding from right edge, connected to PCB
    union() {
        // base on PCB
        translate([pcb_L/2 - port_L/2 + ov, 0, pcb_T/2 + port_H/2 - ov])
            cube([port_L, port_W, port_H], center=true);

        // small protruding shell beyond board edge
        translate([pcb_L/2 + shell_L/2 - ov, 0, pcb_T/2 + (port_H*0.9)/2 - ov])
            cube([shell_L, port_W*0.92, port_H*0.9], center=true);
    }
}

module mcu_qfp(body=14.0, h=1.6, lead=1.2, lead_w=0.6) {
    // MCU package with simple lead flanges; connected to PCB
    union() {
        translate([0, 0, pcb_T/2 + h/2 - ov])
            cube([body, body, h], center=true);

        // lead flanges (4 sides)
        translate([0,  body/2 + lead/2 - ov, pcb_T/2 + (h*0.55)/2 - ov])
            cube([body*0.95, lead, h*0.55], center=true);
        translate([0, -body/2 - lead/2 + ov, pcb_T/2 + (h*0.55)/2 - ov])
            cube([body*0.95, lead, h*0.55], center=true);
        translate([ body/2 + lead/2 - ov, 0, pcb_T/2 + (h*0.55)/2 - ov])
            cube([lead, body*0.95, h*0.55], center=true);
        translate([-body/2 - lead/2 + ov, 0, pcb_T/2 + (h*0.55)/2 - ov])
            cube([lead, body*0.95, h*0.55], center=true);
    }
}

module regulator(body_L=8, body_W=6, body_H=2.2) {
    translate([0, 0, pcb_T/2 + body_H/2 - ov])
        cube([body_L, body_W, body_H], center=true);
}

module led_chip(L=2.0, W=1.2, H=0.8) {
    translate([0, 0, pcb_T/2 + H/2 - ov])
        cube([L, W, H], center=true);
}

// ---------- Assembly ----------
module dev_board() {
    union() {
        // PCB
        color([0.0, 0.4, 0.2]) pcb_base();

        // Two long header rows near left/right edges
        header_len = pcb_L - 2*6.0;
        header_y_offset = pcb_W/2 - 6.0;

        color("Black")
        translate([0,  header_y_offset, 0])
            header_strip(len=header_len, pins=24, body_w=5.0, body_h=8.0);

        color("Black")
        translate([0, -header_y_offset, 0])
            header_strip(len=header_len, pins=24, body_w=5.0, body_h=8.0);

        // USB connector on right edge
        color([0.15, 0.15, 0.15])
        usb_micro_port();

        // MCU near center-left
        color([0.1, 0.1, 0.1])
        translate([-pcb_L*0.12, 0, 0])
            mcu_qfp(body=14.0, h=1.6);

        // Regulator near top-left quadrant
        color([0.1, 0.1, 0.1])
        translate([-pcb_L*0.28, pcb_W*0.22, 0])
            regulator();

        // Small LEDs near top edge
        color([0.9, 0.9, 0.9])
        translate([ pcb_L*0.18, pcb_W*0.30, 0]) led_chip();
        translate([ pcb_L*0.22, pcb_W*0.30, 0]) led_chip();
    }
}

// Final output (one connected solid)
dev_board();