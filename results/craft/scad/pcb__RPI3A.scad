// Single-board computer (generic) 65.0mm x 56.0mm x 1.4mm PCB with connected features
// Output is ONE connected solid (no floating parts).

$fn = 48;

// Parameters
length_mm    = 65.0;  //[32.5:130.0:0.5]
width_mm     = 56.0;  //[28.0:112.0:0.5]
thickness_mm = 1.4;   //[0.7:2.8:0.1]

// Overlap to guarantee physical connection (1–2mm as required)
overlap = 1.2;

// --- Helpers ---
module rounded_rect_prism(l, w, h, r, center=true) {
    translate(center ? [0,0,0] : [l/2, w/2, h/2])
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(l/2 - r), sy*(w/2 - r), 0])
                cylinder(r=r, h=h, center=true);
    }
}

module pcb_base() {
    color([0.0, 0.4, 0.2])
        rounded_rect_prism(length_mm, width_mm, thickness_mm, r=2.0, center=true);
}

module mounting_holes_cut() {
    hole_r = 1.6;
    edge_x = 3.5;
    edge_y = 3.5;

    for (sx = [-1, 1], sy = [-1, 1]) {
        translate([sx*(length_mm/2 - edge_x), sy*(width_mm/2 - edge_y), 0])
            cylinder(r=hole_r, h=thickness_mm + 2, center=true);
    }
}

module pcb_with_holes() {
    difference() {
        pcb_base();
        mounting_holes_cut();
    }
}

// Place a part so its bottom intrudes into PCB top by 'overlap'
function z_on_top(part_h) = (thickness_mm/2) + (part_h/2) - overlap;

// Place a side part so it intrudes into PCB edge by 'overlap'
function x_on_right(part_l) = (length_mm/2) + (part_l/2) - overlap;
function x_on_left(part_l)  = -(length_mm/2) - (part_l/2) + overlap;
function y_on_top(part_l)   = (width_mm/2) + (part_l/2) - overlap;
function y_on_bottom(part_l)= -(width_mm/2) - (part_l/2) + overlap;

module top_components() {
    // All components are placed to INTERSECT the PCB top surface by 'overlap'.
    // This fixes "adjacent but not merged" cases in side views.
    // (No design change; only connectivity.)

    // Main SoC
    soc_l = 14; soc_w = 14; soc_h = 2.0;
    translate([-length_mm*0.08, 0, z_on_top(soc_h)])
        color([0.15,0.15,0.15])
            cube([soc_l, soc_w, soc_h], center=true);

    // RAM / secondary chip
    ram_l = 12; ram_w = 10; ram_h = 1.6;
    translate([length_mm*0.12, width_mm*0.10, z_on_top(ram_h)])
        color([0.18,0.18,0.18])
            cube([ram_l, ram_w, ram_h], center=true);

    // Power management IC
    pm_l = 8; pm_w = 8; pm_h = 1.2;
    translate([length_mm*0.18, -width_mm*0.18, z_on_top(pm_h)])
        color([0.2,0.2,0.2])
            cube([pm_l, pm_w, pm_h], center=true);

    // GPIO header block (2x20 style, generic)
    hdr_l = 52; hdr_w = 6; hdr_h = 8;
    translate([0, width_mm/2 - (hdr_w/2 + 4), z_on_top(hdr_h)])
        color([0.05,0.05,0.05])
            cube([hdr_l, hdr_w, hdr_h], center=true);

    // Camera/Display connector (flat)
    ffc_l = 18; ffc_w = 6; ffc_h = 2.2;
    translate([length_mm/2 - (ffc_l/2 + 6), width_mm*0.05, z_on_top(ffc_h)])
        color([0.85,0.85,0.85])
            cube([ffc_l, ffc_w, ffc_h], center=true);

    // Small passives cluster
    for (i = [0:5]) {
        cap_l = 3.2; cap_w = 2.0; cap_h = 1.2;
        x = -length_mm/2 + 10 + i*4.0;
        y = -width_mm/2 + 10;
        translate([x, y, z_on_top(cap_h)])
            color([0.6,0.6,0.6])
                cube([cap_l, cap_w, cap_h], center=true);
    }
}

module side_connectors() {
    // Side connectors are attached to PCB edges with overlap in X/Y and also overlap into PCB in Z.
    // This fixes "black side protrusions (ports) floating/offset" issues.

    // USB-A like connector on right edge
    usb_l = 14;  // along X (outward)
    usb_w = 13;  // along Y
    usb_h = 7;   // along Z
    translate([x_on_right(usb_l), -width_mm*0.10, z_on_top(usb_h)])
        color([0.75,0.75,0.75])
            cube([usb_l, usb_w, usb_h], center=true);

    // HDMI-like connector on left edge
    hdmi_l = 12;
    hdmi_w = 15;
    hdmi_h = 5.5;
    translate([x_on_left(hdmi_l), width_mm*0.05, z_on_top(hdmi_h)])
        color([0.7,0.7,0.7])
            cube([hdmi_l, hdmi_w, hdmi_h], center=true);

    // Audio jack-like cylinder on left edge
    // Ensure it intersects the PCB edge (X) and the PCB top (Z) by 'overlap'.
    jack_r = 3.2;
    jack_l = 12; // cylinder length along X after rotate
    translate([x_on_left(jack_l), -width_mm*0.25, (thickness_mm/2) + jack_r - overlap])
        rotate([0,90,0])
            color([0.1,0.1,0.1])
                cylinder(r=jack_r, h=jack_l, center=true);

    // Micro-USB/USB-C like power connector on bottom edge
    pwr_w = 9;   // along X
    pwr_l = 7;   // along Y outward
    pwr_h = 3.5; // along Z
    translate([length_mm*0.20, y_on_bottom(pwr_l), z_on_top(pwr_h)])
        color([0.75,0.75,0.75])
            cube([pwr_w, pwr_l, pwr_h], center=true);

    // Ethernet-like connector on top edge (generic)
    eth_w = 16;  // along X
    eth_l = 14;  // along Y outward
    eth_h = 13;  // along Z
    translate([-length_mm*0.18, y_on_top(eth_l), z_on_top(eth_h)])
        color([0.75,0.75,0.75])
            cube([eth_w, eth_l, eth_h], center=true);
}

module edge_connector_blocks() {
    // "Multiple gray connector/component blocks around the PCB perimeter"
    // Ensure they INTERSECT the PCB edge (X/Y) and also overlap into PCB in Z.
    // This fixes floating/disconnected perimeter blocks.

    blk_h = 6;
    blk_w = 10;   // tangential along edge
    blk_l = 8;    // outward from edge

    // Right edge: 2 blocks
    for (y = [-width_mm*0.28, width_mm*0.22]) {
        translate([x_on_right(blk_l), y, z_on_top(blk_h)])
            color([0.65,0.65,0.65])
                cube([blk_l, blk_w, blk_h], center=true);
    }

    // Left edge: 2 blocks (avoid HDMI/jack area)
    for (y = [-width_mm*0.05, width_mm*0.30]) {
        translate([x_on_left(blk_l), y, z_on_top(blk_h)])
            color([0.65,0.65,0.65])
                cube([blk_l, blk_w, blk_h], center=true);
    }

    // Top edge: 2 blocks (avoid GPIO header/ethernet area)
    for (x = [-length_mm*0.35, length_mm*0.30]) {
        translate([x, y_on_top(blk_l), z_on_top(blk_h)])
            color([0.65,0.65,0.65])
                cube([blk_w, blk_l, blk_h], center=true);
    }

    // Bottom edge: 2 blocks (avoid power connector area)
    for (x = [-length_mm*0.25, length_mm*0.35]) {
        translate([x, y_on_bottom(blk_l), z_on_top(blk_h)])
            color([0.65,0.65,0.65])
                cube([blk_w, blk_l, blk_h], center=true);
    }
}

module assembly() {
    // Single connected solid: everything unioned and overlapping by 1–2mm.
    union() {
        pcb_with_holes();
        top_components();
        side_connectors();
        edge_connector_blocks();
    }
}

assembly();