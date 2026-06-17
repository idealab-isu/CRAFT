$fn = 64;

// Target PCB dimensions
pcb_length = 85.0;
pcb_width  = 56.0;
pcb_thickness = 1.4;

// Small overlap to guarantee watertight unions
overlap = 0.2;

// ---------- Helpers ----------
module rounded_plate(L, W, H, r) {
    // Rounded rectangle prism using hull of corner cylinders
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(L/2 - r), sy*(W/2 - r), 0])
                cylinder(r=r, h=H, center=true);
    }
}

module box_solid(L, W, H) {
    cube([L, W, H], center=true);
}

// ---------- SBC Model ----------
module single_board_computer() {

    // PCB with rounded corners + mounting holes (holes are cut through PCB only)
    hole_d = 2.75;
    hole_r = hole_d/2;
    hole_edge = 3.5; // distance from each edge to hole center (typical SBC)
    hole_x = pcb_length/2 - hole_edge;
    hole_y = pcb_width/2  - hole_edge;

    pcb_corner_r = 3.0;

    difference() {
        rounded_plate(pcb_length, pcb_width, pcb_thickness, pcb_corner_r);

        // Mounting holes
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*hole_x, sy*hole_y, 0])
                cylinder(r=hole_r, h=pcb_thickness + 1, center=true);
    }

    // Components (all UNIONED and CONNECTED to PCB with slight overlap)

    // USB-A stack (2 ports) on one long edge
    usb_w = 14.0;   // along Y
    usb_d = 16.0;   // protrusion along X
    usb_h = 15.0;   // height above PCB
    usb_stack_gap = 1.0;
    usb_single_h = (usb_h - usb_stack_gap)/2;

    usb_xc = pcb_length/2 + usb_d/2 - overlap; // connected to +X edge
    usb_yc = -pcb_width/2 + 12.0;              // placed near one corner (formula from width)
    usb_zc1 = pcb_thickness/2 + usb_single_h/2 - overlap;
    usb_zc2 = pcb_thickness/2 + usb_single_h + usb_stack_gap + usb_single_h/2 - overlap;

    translate([usb_xc, usb_yc, usb_zc1]) box_solid(usb_d, usb_w, usb_single_h);
    translate([usb_xc, usb_yc, usb_zc2]) box_solid(usb_d, usb_w, usb_single_h);

    // Ethernet (RJ45) next to USB on same edge
    eth_w = 16.0;
    eth_d = 21.0;
    eth_h = 14.0;

    eth_xc = pcb_length/2 + eth_d/2 - overlap;
    eth_yc = usb_yc + (usb_w/2 + eth_w/2 + 2.0); // adjacent with 2mm gap
    eth_zc = pcb_thickness/2 + eth_h/2 - overlap;

    translate([eth_xc, eth_yc, eth_zc]) box_solid(eth_d, eth_w, eth_h);

    // HDMI on opposite long edge (-X)
    hdmi_w = 15.0;
    hdmi_d = 12.0;
    hdmi_h = 6.0;

    hdmi_xc = -pcb_length/2 - hdmi_d/2 + overlap; // connected to -X edge
    hdmi_yc = 0;
    hdmi_zc = pcb_thickness/2 + hdmi_h/2 - overlap;

    translate([hdmi_xc, hdmi_yc, hdmi_zc]) box_solid(hdmi_d, hdmi_w, hdmi_h);

    // 40-pin header along one long side (+Y), on top of PCB
    hdr_len = 51.0; // along X
    hdr_w   = 5.5;  // along Y
    hdr_h   = 8.5;  // height

    hdr_xc = 0;
    hdr_yc = pcb_width/2 - hdr_w/2 + overlap; // connected to +Y edge
    hdr_zc = pcb_thickness/2 + hdr_h/2 - overlap;

    translate([hdr_xc, hdr_yc, hdr_zc]) box_solid(hdr_len, hdr_w, hdr_h);

    // Main SoC chip near center
    soc_L = 14.0;
    soc_W = 14.0;
    soc_H = 2.0;

    soc_xc = -pcb_length*0.10;
    soc_yc = -pcb_width*0.05;
    soc_zc = pcb_thickness/2 + soc_H/2 - overlap;

    translate([soc_xc, soc_yc, soc_zc]) box_solid(soc_L, soc_W, soc_H);

    // USB-C / power connector on short edge (-Y)
    pwr_w = 9.0;   // along X
    pwr_d = 7.5;   // protrusion along Y
    pwr_h = 3.5;

    pwr_xc = -pcb_length*0.25;
    pwr_yc = -pcb_width/2 - pwr_d/2 + overlap; // connected to -Y edge
    pwr_zc = pcb_thickness/2 + pwr_h/2 - overlap;

    translate([pwr_xc, pwr_yc, pwr_zc]) box_solid(pwr_w, pwr_d, pwr_h);

    // MicroSD slot on bottom side (still connected as one solid by overlapping into PCB)
    sd_L = 16.0; // along X
    sd_W = 14.0; // along Y
    sd_H = 2.0;  // thickness below PCB

    sd_xc = pcb_length*0.20;
    sd_yc = -pcb_width*0.15;
    sd_zc = -pcb_thickness/2 - sd_H/2 + overlap; // overlaps into PCB to keep single solid

    translate([sd_xc, sd_yc, sd_zc]) box_solid(sd_L, sd_W, sd_H);
}

// Render as one connected solid (PCB with holes + attached components)
union() {
    single_board_computer();
}