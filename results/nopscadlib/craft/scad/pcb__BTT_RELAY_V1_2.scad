$fn = 64;

// Target dimensions (mm)
pcb_length = 80.4;
pcb_width  = 36.3;
pcb_thickness = 1.5;

// Small overlap to guarantee watertight unions
ov = 0.25;

// ---------- Helpers ----------
module rounded_rect_prism(L, W, H, r, center=true) {
    // Minkowski gives rounded corners; keep r reasonable
    r2 = min(r, min(L, W)/2 - 0.01);
    minkowski() {
        cube([L - 2*r2, W - 2*r2, H], center=center);
        cylinder(r=r2, h=0.01, center=true);
    }
}

module part_box(size=[10,10,5], pos=[0,0,0], col=[0.8,0.8,0.8]) {
    color(col) translate(pos) cube(size, center=true);
}

module part_cyl(r=2, h=5, pos=[0,0,0], col=[0.8,0.8,0.8]) {
    color(col) translate(pos) cylinder(r=r, h=h, center=true);
}

// ---------- PCB with mounting holes (holes are subtracted) ----------
module pcb_with_holes() {
    corner_r = 1.2;

    // Mounting hole pattern (typical 3D printer controller style)
    hole_r = 1.6;                 // ~3.2mm dia
    hole_edge_x = 4.0;            // from left/right edge
    hole_edge_y = 4.0;            // from top/bottom edge

    xh = pcb_length/2 - hole_edge_x;
    yh = pcb_width/2  - hole_edge_y;

    difference() {
        color([0.0, 0.4, 0.2])
            rounded_rect_prism(pcb_length, pcb_width, pcb_thickness, corner_r, center=true);

        // Through holes
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*xh, sy*yh, 0])
                cylinder(r=hole_r, h=pcb_thickness + 2*ov, center=true);
    }
}

// ---------- Components (all connected to PCB via overlap) ----------
module components_top() {
    // Place components on top surface with slight overlap into PCB
    z_top = pcb_thickness/2;
    // Component heights
    h_usb = 6.0;
    h_term = 8.0;
    h_headers = 5.0;
    h_chip = 2.0;
    h_driver = 3.0;
    h_cap = 6.0;

    // Common z centers (overlap into PCB by ov)
    z_usb    = z_top + h_usb/2    - ov;
    z_term   = z_top + h_term/2   - ov;
    z_head   = z_top + h_headers/2- ov;
    z_chip   = z_top + h_chip/2   - ov;
    z_driver = z_top + h_driver/2 - ov;
    z_cap    = z_top + h_cap/2    - ov;

    // --- Edge connectors ---
    // USB-B like connector on left edge
    usb_len = 12;
    usb_w   = 14;
    part_box(
        [usb_len, usb_w, h_usb],
        [-(pcb_length/2 - usb_len/2), 0, z_usb],
        [0.75, 0.75, 0.75]
    );

    // Power terminal block on right edge
    term_len = 14;
    term_w   = 12;
    part_box(
        [term_len, term_w, h_term],
        [ (pcb_length/2 - term_len/2), pcb_width*0.18, z_term],
        [0.1, 0.55, 0.1]
    );

    // Long pin header along top edge (stepper/IO)
    head_len = pcb_length*0.62;
    head_w   = 6;
    part_box(
        [head_len, head_w, h_headers],
        [0, (pcb_width/2 - head_w/2), z_head],
        [0.15, 0.15, 0.15]
    );

    // Smaller header along bottom edge
    head2_len = pcb_length*0.35;
    head2_w   = 5;
    part_box(
        [head2_len, head2_w, h_headers],
        [pcb_length*0.12, -(pcb_width/2 - head2_w/2), z_head],
        [0.15, 0.15, 0.15]
    );

    // --- Main MCU / IC ---
    mcu_len = 14;
    mcu_w   = 14;
    part_box(
        [mcu_len, mcu_w, h_chip],
        [-pcb_length*0.08, 0, z_chip],
        [0.1, 0.1, 0.1]
    );

    // --- Stepper driver modules (4) ---
    drv_len = 12;
    drv_w   = 16;
    drv_pitch = 18;
    for (i = [0:3]) {
        x = -pcb_length*0.18 + i*drv_pitch;
        y = -pcb_width*0.12;
        part_box(
            [drv_len, drv_w, h_driver],
            [x, y, z_driver],
            [0.2, 0.2, 0.2]
        );
        // Small "heatsink" bump on each driver
        hs_len = 8;
        hs_w   = 8;
        hs_h   = 2.5;
        z_hs = z_top + h_driver - ov + hs_h/2 - ov;
        part_box(
            [hs_len, hs_w, hs_h],
            [x, y, z_hs],
            [0.55, 0.55, 0.55]
        );
    }

    // --- Capacitors (cylinders) ---
    cap_r = 3.0;
    for (p = [
        [ pcb_length*0.28, -pcb_width*0.22],
        [ pcb_length*0.30,  pcb_width*0.05],
        [ pcb_length*0.18,  pcb_width*0.20]
    ]) {
        part_cyl(cap_r, h_cap, [p[0], p[1], z_cap], [0.05,0.05,0.05]);
    }
}

// ---------- Final connected solid ----------
module mainboard() {
    union() {
        pcb_with_holes();
        components_top();
    }
}

mainboard();