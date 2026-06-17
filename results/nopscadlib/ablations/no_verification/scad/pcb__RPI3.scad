$fn = 64;

// Target PCB dimensions (must match exactly)
pcb_length = 85.0;
pcb_width  = 56.0;
pcb_thickness = 1.4;

// Small overlap to guarantee watertight connectivity between parts
overlap = 0.2;

// ---------- Helpers ----------
module rounded_rect_prism(l, w, h, r) {
    r2 = min(r, min(l, w)/2);
    linear_extrude(height=h, center=true)
        offset(r=r2)
            square([l-2*r2, w-2*r2], center=true);
}

module hole_cyl(r, h) {
    cylinder(r=r, h=h, center=true);
}

// ---------- PCB with mounting holes ----------
module pcb_with_holes() {
    corner_r = 3.0;

    // Typical SBC mounting hole pattern (approx), kept within board
    hole_r = 1.45; // ~2.9mm dia
    hole_edge_x = 3.5;
    hole_edge_y = 3.5;

    hole_x = pcb_length/2 - hole_edge_x;
    hole_y = pcb_width/2  - hole_edge_y;

    difference() {
        color([0.0, 0.4, 0.2])
            rounded_rect_prism(pcb_length, pcb_width, pcb_thickness, corner_r);

        // Cut holes through PCB
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*hole_x, sy*hole_y, 0])
                hole_cyl(hole_r, pcb_thickness + 2);
    }
}

// ---------- Components (all connected to PCB) ----------
module usb_stack() {
    // Two stacked USB-A like blocks on one long edge
    usb_w = 16.0;   // along X
    usb_d = 14.0;   // protrusion along +Y
    usb_h = 15.5;   // height above PCB

    // Place centered near one end on +Y edge
    x0 = pcb_length/2 - 22.0;
    y0 = pcb_width/2 + usb_d/2 - overlap;
    z0 = pcb_thickness/2 + usb_h/2 - overlap;

    color([0.75, 0.75, 0.75])
    translate([x0, y0, z0])
        cube([usb_w, usb_d, usb_h], center=true);

    // Second USB next to it
    color([0.75, 0.75, 0.75])
    translate([x0 - (usb_w + 2.0), y0, z0])
        cube([usb_w, usb_d, usb_h], center=true);
}

module ethernet_jack() {
    eth_w = 21.0;  // along X
    eth_d = 16.0;  // protrusion along +Y
    eth_h = 14.0;

    x0 = pcb_length/2 - (eth_w/2 + 4.0);
    y0 = pcb_width/2 + eth_d/2 - overlap;
    z0 = pcb_thickness/2 + eth_h/2 - overlap;

    color([0.65, 0.65, 0.65])
    translate([x0, y0, z0])
        cube([eth_w, eth_d, eth_h], center=true);
}

module hdmi_port() {
    hdmi_w = 15.0; // along X
    hdmi_d = 11.0; // protrusion along -Y
    hdmi_h = 6.0;

    x0 = -pcb_length/2 + 18.0;
    y0 = -pcb_width/2 - hdmi_d/2 + overlap;
    z0 = pcb_thickness/2 + hdmi_h/2 - overlap;

    color([0.55, 0.55, 0.55])
    translate([x0, y0, z0])
        cube([hdmi_w, hdmi_d, hdmi_h], center=true);
}

module audio_jack() {
    jack_r = 3.5;
    jack_len = 12.0; // protrusion along -Y

    x0 = -pcb_length/2 + 6.5;
    y0 = -pcb_width/2 - jack_len/2 + overlap;
    z0 = pcb_thickness/2 + jack_r - overlap;

    color([0.1, 0.1, 0.1])
    translate([x0, y0, z0])
        rotate([90, 0, 0])
            cylinder(r=jack_r, h=jack_len, center=true);
}

module gpio_header() {
    // 2x20 header block
    hdr_w = 51.0; // along X
    hdr_d = 6.0;  // along Y
    hdr_h = 8.5;

    x0 = 0;
    y0 = pcb_width/2 - (hdr_d/2 + 6.0);
    z0 = pcb_thickness/2 + hdr_h/2 - overlap;

    color([0.05, 0.05, 0.05])
    translate([x0, y0, z0])
        cube([hdr_w, hdr_d, hdr_h], center=true);
}

module main_chip() {
    chip_w = 14.0;
    chip_d = 14.0;
    chip_h = 2.0;

    x0 = -8.0;
    y0 = 0.0;
    z0 = pcb_thickness/2 + chip_h/2 - overlap;

    color([0.12, 0.12, 0.12])
    translate([x0, y0, z0])
        cube([chip_w, chip_d, chip_h], center=true);
}

module usb_c_power() {
    // Small USB-C power connector on -Y edge
    c_w = 9.0;   // along X
    c_d = 7.5;   // protrusion along -Y
    c_h = 3.5;

    x0 = pcb_length/2 - 10.0;
    y0 = -pcb_width/2 - c_d/2 + overlap;
    z0 = pcb_thickness/2 + c_h/2 - overlap;

    color([0.6, 0.6, 0.6])
    translate([x0, y0, z0])
        cube([c_w, c_d, c_h], center=true);
}

// ---------- Complete SBC (single connected solid) ----------
module sbc_complete_model() {
    union() {
        pcb_with_holes();

        // Edge connectors (all overlap into PCB by 'overlap')
        ethernet_jack();
        usb_stack();
        hdmi_port();
        audio_jack();
        usb_c_power();

        // On-board components
        gpio_header();
        main_chip();
    }
}

sbc_complete_model();