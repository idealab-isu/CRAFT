$fn = 64;

// =====================
// Parameters (mm)
// =====================
pcb_length = 85.0;
pcb_width  = 56.0;
pcb_thickness = 1.4;

fillet_radius = 3.0;

mounting_hole_diameter = 3.0;
mounting_hole_offset_x = 5.0;
mounting_hole_offset_y = 5.0;

// Small overlap to guarantee watertight unions
eps = 0.2;

// =====================
// Helpers
// =====================
module rounded_plate_xy(l, w, h, r) {
    // Centered at origin, Z from 0..h
    hull() {
        translate([-(l/2 - r), -(w/2 - r), 0]) cylinder(h=h, r=r);
        translate([ (l/2 - r), -(w/2 - r), 0]) cylinder(h=h, r=r);
        translate([-(l/2 - r),  (w/2 - r), 0]) cylinder(h=h, r=r);
        translate([ (l/2 - r),  (w/2 - r), 0]) cylinder(h=h, r=r);
    }
}

module mounting_holes_cut() {
    // Through-holes, centered board coordinates
    for (sx = [-1, 1])
        for (sy = [-1, 1])
            translate([sx*(pcb_length/2 - mounting_hole_offset_x),
                       sy*(pcb_width/2  - mounting_hole_offset_y),
                       -eps])
                cylinder(h=pcb_thickness + 2*eps, d=mounting_hole_diameter);
}

// Simple component primitives (all placed to TOUCH/OVERLAP the PCB)
module chip(x, y, lx, wy, hz) {
    translate([x, y, pcb_thickness - eps])
        cube([lx, wy, hz], center=false);
}

module header_pinblock(x, y, lx, wy, hz) {
    translate([x, y, pcb_thickness - eps])
        cube([lx, wy, hz], center=false);
}

module side_connector_on_edge(edge="right", y_center=0, conn_w=16, conn_d=14, conn_h=12) {
    // Connector protrudes outward from PCB edge, but overlaps into PCB by eps
    // conn_w along Y, conn_d along X (outward), conn_h along Z
    if (edge == "right") {
        translate([ pcb_length/2 - eps, y_center - conn_w/2, pcb_thickness - eps])
            cube([conn_d, conn_w, conn_h], center=false);
    } else if (edge == "left") {
        translate([-(pcb_length/2 + conn_d - eps), y_center - conn_w/2, pcb_thickness - eps])
            cube([conn_d, conn_w, conn_h], center=false);
    } else if (edge == "top") { // +Y edge
        translate([x_center - conn_w/2, pcb_width/2 - eps, pcb_thickness - eps])
            cube([conn_w, conn_d, conn_h], center=false);
    } else if (edge == "bottom") { // -Y edge
        translate([x_center - conn_w/2, -(pcb_width/2 + conn_d - eps), pcb_thickness - eps])
            cube([conn_w, conn_d, conn_h], center=false);
    }
}

// =====================
// Main PCB body
// =====================
module pcb_body() {
    difference() {
        rounded_plate_xy(pcb_length, pcb_width, pcb_thickness, fillet_radius);
        mounting_holes_cut();
    }
}

// =====================
// Components (kept simple but recognizable)
// All components are UNIONED with PCB to ensure ONE connected solid.
// =====================
module components() {
    // Large SoC
    chip(-10, -6, 14, 14, 2.0);

    // RAM / secondary chip
    chip(8, -6, 12, 10, 1.8);

    // Power management
    chip(-18, 10, 10, 8, 1.6);

    // 40-pin header block along top edge (inside board)
    header_len = 52;
    header_w   = 6;
    header_h   = 8;
    translate([-(header_len/2), pcb_width/2 - header_w - 3, pcb_thickness - eps])
        cube([header_len, header_w, header_h], center=false);

    // USB-like stacked connector on right edge
    // Two stacked blocks to suggest dual ports
    usb_w = 16;
    usb_d = 14;
    usb_h = 7;
    y_usb = 8;
    translate([pcb_length/2 - eps, y_usb - usb_w/2, pcb_thickness - eps])
        cube([usb_d, usb_w, usb_h], center=false);
    translate([pcb_length/2 - eps, y_usb - usb_w/2, pcb_thickness - eps + usb_h - eps])
        cube([usb_d, usb_w, usb_h], center=false);

    // Ethernet-like connector on right edge below USB
    eth_w = 16;
    eth_d = 16;
    eth_h = 13;
    y_eth = -14;
    translate([pcb_length/2 - eps, y_eth - eth_w/2, pcb_thickness - eps])
        cube([eth_d, eth_w, eth_h], center=false);

    // HDMI-like connector on bottom edge (protrudes -Y)
    hdmi_w = 14;   // along X
    hdmi_d = 10;   // outward along Y
    hdmi_h = 5;
    x_hdmi = 10;
    translate([x_hdmi - hdmi_w/2, -(pcb_width/2 + hdmi_d - eps), pcb_thickness - eps])
        cube([hdmi_w, hdmi_d, hdmi_h], center=false);

    // USB-C / power connector on bottom edge
    pwr_w = 9;
    pwr_d = 8;
    pwr_h = 4.5;
    x_pwr = -18;
    translate([x_pwr - pwr_w/2, -(pcb_width/2 + pwr_d - eps), pcb_thickness - eps])
        cube([pwr_w, pwr_d, pwr_h], center=false);

    // Camera/Display FFC connector on left edge
    ffc_w = 10;  // along Y
    ffc_d = 6;   // outward along X
    ffc_h = 3.5;
    y_ffc = 18;
    translate([-(pcb_length/2 + ffc_d - eps), y_ffc - ffc_w/2, pcb_thickness - eps])
        cube([ffc_d, ffc_w, ffc_h], center=false);

    // MicroSD-like slot on bottom side (as a shallow protrusion)
    sd_w = 16; // along X
    sd_d = 12; // along Y outward (-Y)
    sd_h = 2.2;
    x_sd = -30;
    translate([x_sd - sd_w/2, -(pcb_width/2 + sd_d - eps), pcb_thickness - eps])
        cube([sd_w, sd_d, sd_h], center=false);
}

// =====================
// Assemble: ONE connected solid
// =====================
union() {
    pcb_body();
    components();
}