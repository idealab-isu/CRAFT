$fn = 64;

// Requested overall PCB size (simple thin rectangular PCB)
pcb_L = 51.0;
pcb_W = 21.0;
pcb_T = 1.6;

// Overlap to guarantee watertight unions (1–2mm as requested)
ov = 1.2;

// Corner radius (kept modest)
corner_r = 2.0;

// Mounting holes (kept, but on the rectangular PCB)
hole_d = 2.6;
hole_edge_x = 3.0;
hole_edge_y = 3.0;

// Simple SBC-like components (small, mounted on top face)
usb_L = 7.0;
usb_W = 9.0;
usb_H = 4.0;

hdmi_L = 6.0;
hdmi_W = 8.0;
hdmi_H = 3.0;

header_L = 20.0;
header_W = 5.0;
header_H = 3.0;

chip_L = 12.0;
chip_W = 12.0;
chip_H = 1.6;

reg_L = 8.0;
reg_W = 6.0;
reg_H = 1.2;

module rounded_rect_2d(L, W, r) {
    r2 = min(r, min(L, W)/2);
    hull() {
        translate([ L/2 - r2,  W/2 - r2]) circle(r=r2);
        translate([-L/2 + r2,  W/2 - r2]) circle(r=r2);
        translate([ L/2 - r2, -W/2 + r2]) circle(r=r2);
        translate([-L/2 + r2, -W/2 + r2]) circle(r=r2);
    }
}

module pcb_plate() {
    // Flat rectangular PCB as the primary body (51 x 21 x 1.6)
    linear_extrude(height=pcb_T, center=true)
        rounded_rect_2d(pcb_L, pcb_W, corner_r);
}

module mounting_holes() {
    for (sx = [-1, 1], sy = [-1, 1]) {
        translate([ sx*(pcb_L/2 - hole_edge_x), sy*(pcb_W/2 - hole_edge_y), 0 ])
            cylinder(h=pcb_T + 2, d=hole_d, center=true);
    }
}

module usb_connector() {
    // On +X edge, centered in Y; overlaps into PCB by ov
    translate([
        pcb_L/2 + usb_L/2 - ov,
        0,
        pcb_T/2 + usb_H/2 - ov
    ])
        cube([usb_L, usb_W, usb_H], center=true);
}

module hdmi_connector() {
    // On -X edge, slightly offset in Y; overlaps into PCB by ov
    translate([
        -pcb_L/2 - hdmi_L/2 + ov,
        -pcb_W*0.18,
        pcb_T/2 + hdmi_H/2 - ov
    ])
        cube([hdmi_L, hdmi_W, hdmi_H], center=true);
}

module gpio_header() {
    // Along +Y edge; overlaps into PCB by ov
    translate([
        0,
        pcb_W/2 + header_W/2 - ov,
        pcb_T/2 + header_H/2 - ov
    ])
        cube([header_L, header_W, header_H], center=true);
}

module main_chip() {
    // On top face; overlaps into PCB by ov
    translate([
        -pcb_L*0.10,
        0,
        pcb_T/2 + chip_H/2 - ov
    ])
        cube([chip_L, chip_W, chip_H], center=true);
}

module regulator() {
    // On top face; overlaps into PCB by ov
    translate([
        pcb_L*0.18,
        -pcb_W*0.22,
        pcb_T/2 + reg_H/2 - ov
    ])
        cube([reg_L, reg_W, reg_H], center=true);
}

module sbc() {
    union() {
        // Thin PCB with holes (still a single solid after union with components)
        difference() {
            pcb_plate();
            mounting_holes();
        }

        // Components/connectors (all connected via overlap into PCB)
        usb_connector();
        hdmi_connector();
        gpio_header();
        main_chip();
        regulator();
    }
}

sbc();