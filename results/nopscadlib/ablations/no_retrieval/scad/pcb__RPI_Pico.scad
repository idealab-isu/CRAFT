$fn = 64;

// Target board dimensions (mm)
pcb_L = 51.0;
pcb_W = 21.0;
pcb_T = 1.6;

// Detail parameters (kept proportional; all placements are formula-based)
corner_r = 1.2;          // rounded corner radius
hole_d   = 2.2;          // mounting hole diameter
hole_edge_clear = 3.0;   // hole center offset from each edge

// Component heights (above PCB)
chip_h   = 1.2;
conn_h   = 3.2;
header_h = 2.6;

// Small overlap to guarantee watertight unions
ov = 0.2;

// ---------- Helpers ----------
module rounded_rect_2d(L, W, r) {
    // 2D rounded rectangle centered at origin
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(L/2 - r), sy*(W/2 - r)])
                circle(r=r);
    }
}

module pcb_plate() {
    // PCB with rounded corners and 4 mounting holes
    difference() {
        linear_extrude(height=pcb_T, center=true)
            rounded_rect_2d(pcb_L, pcb_W, corner_r);

        // Mounting holes (through)
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*(pcb_L/2 - hole_edge_clear), sy*(pcb_W/2 - hole_edge_clear), 0])
                cylinder(h=pcb_T + 2, d=hole_d, center=true);
        }
    }
}

module top_components() {
    // All components are placed so their bottoms slightly overlap into the PCB
    z0 = pcb_T/2;

    union() {
        // Main IC
        ic_L = pcb_L * 0.28;
        ic_W = pcb_W * 0.38;
        translate([-(pcb_L*0.10), 0, z0 + chip_h/2 - ov])
            cube([ic_L, ic_W, chip_h], center=true);

        // USB-like connector on +X edge
        usb_L = pcb_L * 0.18;
        usb_W = pcb_W * 0.45;
        usb_H = conn_h;
        translate([pcb_L/2 - usb_L/2 + ov, 0, z0 + usb_H/2 - ov])
            cube([usb_L, usb_W, usb_H], center=true);

        // Small connector on -X edge
        pwr_L = pcb_L * 0.14;
        pwr_W = pcb_W * 0.30;
        pwr_H = conn_h * 0.85;
        translate([-(pcb_L/2 - pwr_L/2 + ov), pcb_W*0.18, z0 + pwr_H/2 - ov])
            cube([pwr_L, pwr_W, pwr_H], center=true);

        // Pin header along -Y edge
        hdr_L = pcb_L * 0.70;
        hdr_W = pcb_W * 0.12;
        hdr_H = header_h;
        translate([0, -(pcb_W/2 - hdr_W/2 + ov), z0 + hdr_H/2 - ov])
            cube([hdr_L, hdr_W, hdr_H], center=true);

        // A couple of small passives
        smd_L = pcb_L * 0.08;
        smd_W = pcb_W * 0.06;
        smd_H = 0.8;
        translate([pcb_L*0.12, pcb_W*0.18, z0 + smd_H/2 - ov])
            cube([smd_L, smd_W, smd_H], center=true);
        translate([pcb_L*0.18, -pcb_W*0.10, z0 + smd_H/2 - ov])
            cube([smd_L, smd_W, smd_H], center=true);
    }
}

// ---------- Final Model (ONE connected solid) ----------
module single_board_computer() {
    union() {
        color([0.0, 0.4, 0.2]) pcb_plate();
        color([0.15, 0.15, 0.15]) top_components();
    }
}

single_board_computer();