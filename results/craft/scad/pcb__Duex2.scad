$fn = 64;

// Board parameters (exact)
length = 123.0;
width  = 100.0;
thickness = 1.6;
corner_radius = 0.0;

// Small overlap to guarantee one connected solid
overlap = 0.25;

// Helpers
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

module rounded_board(L, W, T, R) {
    R2 = clamp(R, 0, min(L, W)/2);
    if (R2 <= 0) {
        cube([L, W, T], center=true);
    } else {
        linear_extrude(height=T, center=true)
            offset(r=R2)
                square([L - 2*R2, W - 2*R2], center=true);
    }
}

module standoff(r=3.2, h=3.0) {
    cylinder(r=r, h=h, center=true);
}

module chip(body=[18,18,2.2], lead=0.6) {
    // Simple IC package with slight base lip
    union() {
        cube(body, center=true);
        translate([0,0,-(body[2]/2 + lead/2 - overlap)])
            cube([body[0]+2, body[1]+2, lead], center=true);
    }
}

module connector_block(size=[14,10,10], notch=2) {
    // Generic connector with a small top notch
    difference() {
        cube(size, center=true);
        translate([0, 0, size[2]/2 - notch/2 + overlap])
            cube([size[0]*0.6, size[1]*0.6, notch], center=true);
    }
}

module usb_like(size=[16,14,8]) {
    // Simple USB-like housing
    union() {
        cube(size, center=true);
        translate([0, 0, size[2]/2 + 1.2/2 - overlap])
            cube([size[0]*0.9, size[1]*0.7, 1.2], center=true);
    }
}

module terminal_block(size=[40,12,12], slots=6) {
    // Long terminal block with shallow slot pattern
    difference() {
        cube(size, center=true);
        for (i = [0:slots-1]) {
            x = -size[0]/2 + (i+0.5)*size[0]/slots;
            translate([x, 0, size[2]/2 - 2/2 + overlap])
                cube([size[0]/slots*0.7, size[1]*0.7, 2], center=true);
        }
    }
}

module board_with_holes() {
    hole_d = 3.2;
    edge_margin = 6.0;

    // Hole positions derived from board dimensions
    hx = length/2 - edge_margin;
    hy = width/2  - edge_margin;

    difference() {
        rounded_board(length, width, thickness, corner_radius);

        // 4 mounting holes
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*hx, sy*hy, 0])
                cylinder(d=hole_d, h=thickness + 2, center=true);
        }
    }
}

module components_top() {
    // Place components on top surface; all Z are formulas from thickness and component heights
    pcb_top_z = thickness/2;

    // Main MCU/SoC
    mcu = [22, 22, 2.6];
    translate([0, 0, pcb_top_z + mcu[2]/2 - overlap])
        chip(body=mcu, lead=0.7);

    // Driver chips row (e.g., stepper drivers)
    drv = [14, 14, 2.4];
    drv_y = -width*0.18;
    drv_x_span = length*0.55;
    for (i = [0:3]) {
        x = -drv_x_span/2 + i*(drv_x_span/3);
        translate([x, drv_y, pcb_top_z + drv[2]/2 - overlap])
            chip(body=drv, lead=0.6);
    }

    // USB-like connector on one edge
    usb = [16, 14, 8];
    translate([-(length/2 - usb[0]/2), width*0.15, pcb_top_z + usb[2]/2 - overlap])
        usb_like(size=usb);

    // Terminal block along opposite edge
    term = [46, 12, 12];
    translate([length/2 - term[0]/2, 0, pcb_top_z + term[2]/2 - overlap])
        terminal_block(size=term, slots=7);

    // Two mid-size connectors
    conn = [18, 10, 10];
    translate([0, width/2 - conn[1]/2, pcb_top_z + conn[2]/2 - overlap])
        connector_block(size=conn, notch=2);

    translate([length*0.25, width/2 - conn[1]/2, pcb_top_z + conn[2]/2 - overlap])
        connector_block(size=conn, notch=2);

    // Capacitors (simple cylinders)
    cap_r = 4.0;
    cap_h = 9.0;
    for (i = [0:2]) {
        x = -length*0.25 + i*(length*0.12);
        y = width*0.22;
        translate([x, y, pcb_top_z + cap_h/2 - overlap])
            cylinder(r=cap_r, h=cap_h, center=true);
    }

    // Standoffs around mounting holes (connected to PCB)
    st_r = 3.6;
    st_h = 3.0;
    edge_margin = 6.0;
    hx = length/2 - edge_margin;
    hy = width/2  - edge_margin;
    for (sx = [-1, 1], sy = [-1, 1]) {
        translate([sx*hx, sy*hy, pcb_top_z + st_h/2 - overlap])
            standoff(r=st_r, h=st_h);
    }
}

module Duex2_control_board() {
    // One connected solid: union of PCB (with holes) + components that overlap into PCB
    union() {
        color([0.0, 0.4, 0.2]) board_with_holes();
        color([0.15, 0.15, 0.15]) components_top();
    }
}

// Assembly
Duex2_control_board();