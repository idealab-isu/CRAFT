$fn = 48;

// Target PCB dimensions (mm)
pcb_length = 85.0;
pcb_width  = 56.0;
pcb_thickness = 1.4;

// Small overlap to guarantee watertight unions
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

module place_on_top(z0, h) {
    // Places a centered object of height h so its bottom slightly overlaps the PCB top
    translate([0, 0, z0 + h/2 - overlap]) children();
}

// ---------- SBC Model ----------
module sbc_complete_model() {

    // PCB with mounting holes (difference keeps it one solid with holes)
    pcb_corner_r = 3.0;
    hole_r = 1.6; // ~3.2mm dia
    hole_edge_x = 3.5;
    hole_edge_y = 3.5;

    z_pcb_top = pcb_thickness/2;

    union() {
        // PCB body with holes
        color([0.0, 0.4, 0.2])
        difference() {
            rounded_rect_prism(pcb_length, pcb_width, pcb_thickness, pcb_corner_r, center=true);

            for (sx = [-1, 1], sy = [-1, 1]) {
                translate([sx*(pcb_length/2 - hole_edge_x), sy*(pcb_width/2 - hole_edge_y), 0])
                    cylinder(h=pcb_thickness + 2*overlap, r=hole_r, center=true);
            }
        }

        // Components/connectors (all connected by slight overlap into PCB)

        // 40-pin header (approx) along one long edge
        hdr_l = 51.0;
        hdr_w = 5.5;
        hdr_h = 8.5;
        hdr_y = pcb_width/2 - hdr_w/2;
        place_on_top(z_pcb_top, hdr_h)
            translate([0, hdr_y, 0])
                color([0.1, 0.1, 0.1])
                    cube([hdr_l, hdr_w, hdr_h], center=true);

        // USB-A stack (2 ports) on one short edge
        usb_w = 16.0;   // along Y
        usb_d = 14.0;   // along X (sticks out)
        usb_h = 15.0;
        usb_x = pcb_length/2 - usb_d/2; // centered so it reaches the edge
        usb_y = -pcb_width*0.18;
        place_on_top(z_pcb_top, usb_h)
            translate([usb_x, usb_y, 0])
                color([0.75, 0.75, 0.75])
                    cube([usb_d, usb_w, usb_h], center=true);

        // Ethernet jack next to USB
        eth_w = 16.0;
        eth_d = 21.0;
        eth_h = 14.0;
        eth_x = pcb_length/2 - eth_d/2;
        eth_y = pcb_width*0.18;
        place_on_top(z_pcb_top, eth_h)
            translate([eth_x, eth_y, 0])
                color([0.7, 0.7, 0.7])
                    cube([eth_d, eth_w, eth_h], center=true);

        // HDMI connector on opposite long edge
        hdmi_l = 15.0;  // along X
        hdmi_w = 11.0;  // along Y (sticks out)
        hdmi_h = 6.0;
        hdmi_y = -pcb_width/2 + hdmi_w/2;
        hdmi_x = -pcb_length*0.10;
        place_on_top(z_pcb_top, hdmi_h)
            translate([hdmi_x, hdmi_y, 0])
                color([0.6, 0.6, 0.6])
                    cube([hdmi_l, hdmi_w, hdmi_h], center=true);

        // Micro-USB / USB-C power connector near HDMI
        pwr_l = 8.0;
        pwr_w = 7.0;
        pwr_h = 4.0;
        pwr_y = -pcb_width/2 + pwr_w/2;
        pwr_x = -pcb_length*0.32;
        place_on_top(z_pcb_top, pwr_h)
            translate([pwr_x, pwr_y, 0])
                color([0.65, 0.65, 0.65])
                    cube([pwr_l, pwr_w, pwr_h], center=true);

        // SoC package (square IC) near center
        soc_s = 14.0;
        soc_h = 2.0;
        soc_x = -pcb_length*0.05;
        soc_y = 0;
        place_on_top(z_pcb_top, soc_h)
            translate([soc_x, soc_y, 0])
                color([0.15, 0.15, 0.15])
                    cube([soc_s, soc_s, soc_h], center=true);

        // Camera/Display FFC connector (small) on top edge
        ffc_l = 18.0;
        ffc_w = 6.0;
        ffc_h = 3.0;
        ffc_y = pcb_width/2 - ffc_w/2;
        ffc_x = pcb_length*0.28;
        place_on_top(z_pcb_top, ffc_h)
            translate([ffc_x, ffc_y, 0])
                color([0.85, 0.85, 0.85])
                    cube([ffc_l, ffc_w, ffc_h], center=true);
    }
}

// Render
sbc_complete_model();