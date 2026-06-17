$fn = 64;

// Parameters (target PCB size)
pcb_length = 85.0;   // X
pcb_width  = 56.0;   // Y
pcb_thickness = 1.4; // Z

// Small overlap to guarantee watertight unions
overlap = 0.2;

// Helper: rounded rectangle prism (centered)
module rounded_box(size=[10,10,2], r=1, center=true) {
    x = size[0]; y = size[1]; z = size[2];
    rr = min(r, x/2, y/2);
    translate(center ? [0,0,0] : [x/2,y/2,z/2])
        linear_extrude(height=z, center=true)
            offset(r=rr)
                square([x-2*rr, y-2*rr], center=true);
}

// PCB with mounting holes (holes are cut, but model remains one connected solid)
module pcb() {
    hole_d = 2.75;
    hole_r = hole_d/2;

    // Typical SBC hole offsets from edges (kept parametric and derived from board dims)
    edge_x = 3.5;
    edge_y = 3.5;

    xh = pcb_length/2 - edge_x;
    yh = pcb_width/2  - edge_y;

    difference() {
        color([0.0, 0.4, 0.2])
            rounded_box([pcb_length, pcb_width, pcb_thickness], r=2.0, center=true);

        // 4 mounting holes
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*xh, sy*yh, 0])
                cylinder(h=pcb_thickness + 2*overlap, r=hole_r, center=true);
    }
}

// Simple connector/component blocks that are guaranteed to touch the PCB top surface
module components() {
    z_top = pcb_thickness/2;

    // USB-A stack (2 ports) along +X edge
    usb_w = 16.0;   // along X (depth into board)
    usb_l = 14.0;   // along Y
    usb_h = 15.0;   // above PCB
    usb_gap = 2.0;

    usb_xc = pcb_length/2 - usb_w/2 + overlap; // overlaps into PCB
    usb_y1 = pcb_width/2 - usb_l/2 - 6.0;
    usb_y2 = usb_y1 - (usb_l + usb_gap);

    for (yy = [usb_y1, usb_y2])
        color([0.75, 0.75, 0.75])
            translate([usb_xc, yy, z_top + usb_h/2 - overlap])
                cube([usb_w, usb_l, usb_h], center=true);

    // Ethernet block near USBs along +X edge
    eth_w = 21.0;
    eth_l = 16.0;
    eth_h = 14.0;

    eth_xc = pcb_length/2 - eth_w/2 + overlap;
    eth_yc = usb_y2 - (usb_l/2 + eth_l/2 + 3.0);

    color([0.65, 0.65, 0.65])
        translate([eth_xc, eth_yc, z_top + eth_h/2 - overlap])
            cube([eth_w, eth_l, eth_h], center=true);

    // HDMI block along -Y edge
    hdmi_w = 12.0;  // along X
    hdmi_l = 10.0;  // along Y (depth into board)
    hdmi_h = 6.0;

    hdmi_yc = -pcb_width/2 + hdmi_l/2 - overlap;
    hdmi_xc = -pcb_length/2 + 32.0;

    color([0.25, 0.25, 0.25])
        translate([hdmi_xc, hdmi_yc, z_top + hdmi_h/2 - overlap])
            cube([hdmi_w, hdmi_l, hdmi_h], center=true);

    // 40-pin header block along +Y edge
    hdr_w = 52.0;  // along X
    hdr_l = 6.0;   // along Y (depth into board)
    hdr_h = 8.5;

    hdr_yc = pcb_width/2 - hdr_l/2 + overlap;
    hdr_xc = -pcb_length/2 + 42.0;

    color([0.1, 0.1, 0.1])
        translate([hdr_xc, hdr_yc, z_top + hdr_h/2 - overlap])
            cube([hdr_w, hdr_l, hdr_h], center=true);

    // Main SoC block on top
    soc_s = 14.0;
    soc_h = 2.0;
    soc_xc = -pcb_length/2 + 30.0;
    soc_yc = 0;

    color([0.15, 0.15, 0.15])
        translate([soc_xc, soc_yc, z_top + soc_h/2 - overlap])
            cube([soc_s, soc_s, soc_h], center=true);

    // USB-C / power block along -X edge
    pwr_w = 9.0;   // along X (depth into board)
    pwr_l = 8.0;   // along Y
    pwr_h = 3.5;

    pwr_xc = -pcb_length/2 + pwr_w/2 - overlap;
    pwr_yc = -pcb_width/2 + 14.0;

    color([0.7, 0.7, 0.7])
        translate([pwr_xc, pwr_yc, z_top + pwr_h/2 - overlap])
            cube([pwr_w, pwr_l, pwr_h], center=true);
}

// Final Output: one connected solid (PCB + components all touching/overlapping)
union() {
    pcb();
    components();
}