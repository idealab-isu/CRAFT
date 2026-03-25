// Single-board computer (Raspberry Pi Pico-like) proxy model
// Target PCB: 51.0mm x 21.0mm x 1.6mm
// One connected solid; all placements are dimension-derived (no arbitrary floating).

$fn = 48;

// Parameters
length_mm = 51.0;      // X
width_mm  = 21.0;      // Y
thickness_mm = 1.6;    // Z
corner_radius_mm = 1.0;

// Small overlap to guarantee watertight unions
overlap = 0.25;

// ---------- Helpers ----------
module rounded_plate(l, w, h, r) {
    // Rounded rectangle prism using hull of corner cylinders
    r2 = min(r, min(l, w)/2);
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(l/2 - r2), sy*(w/2 - r2), 0])
                cylinder(r=r2, h=h, center=true);
    }
}

module pin_header_row(n=20, pitch=2.54, pin_w=0.64, pin_h=3.0, body_h=2.5, body_w=2.5) {
    // A single row header: plastic body + pins
    row_len = (n-1)*pitch + body_w;
    union() {
        // Plastic body
        translate([0, 0, 0])
            cube([row_len, body_w, body_h], center=true);

        // Pins (extend downward)
        for (i = [0:n-1]) {
            x = -row_len/2 + body_w/2 + i*pitch;
            translate([x, 0, -(body_h/2 + pin_h/2 - overlap)])
                cube([pin_w, pin_w, pin_h], center=true);
        }
    }
}

module usb_micro_b_shell(w=7.5, d=5.8, h=2.6) {
    // Simple micro-USB-like metal shell block
    cube([w, d, h], center=true);
}

module qfn_chip(body=7.0, h=1.0) {
    cube([body, body, h], center=true);
}

module small_ic(l=8.0, w=6.0, h=1.2) {
    cube([l, w, h], center=true);
}

// ---------- Main SBC ----------
module SBC_51x21() {
    // Derived constants
    pcb_l = length_mm;
    pcb_w = width_mm;
    pcb_t = thickness_mm;

    // Component sizes (kept plausible, not exact)
    usb_w = 7.5;
    usb_d = 5.8;
    usb_h = 2.6;

    header_n = 20;
    header_pitch = 2.54;
    header_body_h = 2.5;
    header_body_w = 2.5;
    header_pin_h  = 3.0;

    // Header row length
    header_len = (header_n-1)*header_pitch + header_body_w;

    // Placement formulas (all connected with overlap)
    pcb_top_z = pcb_t/2;
    pcb_bot_z = -pcb_t/2;

    // USB at +X edge, centered in Y, sitting on top of PCB
    usb_center_x = pcb_l/2 + usb_d/2 - overlap; // overlaps into PCB edge
    usb_center_y = 0;
    usb_center_z = pcb_top_z + usb_h/2 - overlap;

    // Headers along long edges (Y = +/-), centered in X
    header_center_x = 0;
    header_offset_y = pcb_w/2 - header_body_w/2 + overlap; // overlaps into PCB
    header_center_z = pcb_top_z + header_body_h/2 - overlap;

    // MCU and flash on top
    mcu_body = 7.0;
    mcu_h = 1.0;
    mcu_center_x = -pcb_l*0.05;
    mcu_center_y = 0;
    mcu_center_z = pcb_top_z + mcu_h/2 - overlap;

    flash_l = 8.0;
    flash_w = 6.0;
    flash_h = 1.2;
    flash_center_x = pcb_l*0.18;
    flash_center_y = 0;
    flash_center_z = pcb_top_z + flash_h/2 - overlap;

    // A small button near -X end
    btn_l = 4.0;
    btn_w = 3.0;
    btn_h = 1.5;
    btn_center_x = -pcb_l/2 + 6.0;
    btn_center_y = 0;
    btn_center_z = pcb_top_z + btn_h/2 - overlap;

    // Keep everything as ONE connected solid
    union() {
        // PCB
        color([0.0, 0.4, 0.2])
            rounded_plate(pcb_l, pcb_w, pcb_t, corner_radius_mm);

        // USB connector
        color([0.75, 0.75, 0.78])
            translate([usb_center_x, usb_center_y, usb_center_z])
                usb_micro_b_shell(usb_w, usb_d, usb_h);

        // Pin headers (two rows)
        color([0.1, 0.1, 0.1])
            translate([header_center_x,  header_offset_y, header_center_z])
                pin_header_row(n=header_n, pitch=header_pitch, body_h=header_body_h, body_w=header_body_w, pin_h=header_pin_h);

        color([0.1, 0.1, 0.1])
            translate([header_center_x, -header_offset_y, header_center_z])
                pin_header_row(n=header_n, pitch=header_pitch, body_h=header_body_h, body_w=header_body_w, pin_h=header_pin_h);

        // MCU
        color([0.15, 0.15, 0.15])
            translate([mcu_center_x, mcu_center_y, mcu_center_z])
                qfn_chip(body=mcu_body, h=mcu_h);

        // Flash / secondary IC
        color([0.18, 0.18, 0.18])
            translate([flash_center_x, flash_center_y, flash_center_z])
                small_ic(l=flash_l, w=flash_w, h=flash_h);

        // Button
        color([0.2, 0.2, 0.2])
            translate([btn_center_x, btn_center_y, btn_center_z])
                cube([btn_l, btn_w, btn_h], center=true);
    }
}

// Assembly
module assembly() {
    SBC_51x21();
}

assembly();