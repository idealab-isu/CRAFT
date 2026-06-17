$fn = 64;

// Target PCB dimensions (mm)
pcb_length    = 80.4;
pcb_width     = 36.3;
pcb_thickness = 1.5;

// Small overlap to guarantee watertight unions
ov = 0.25;

// ---------- Helpers ----------
module rounded_rect_2d(l, w, r) {
    // Robust rounded rectangle (no offset artifacts)
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(l/2 - r), sy*(w/2 - r)]) circle(r=r);
    }
}

module pcb_body(l, w, t, r) {
    linear_extrude(height=t, center=true)
        rounded_rect_2d(l, w, r);
}

module cut_hole(x, y, d, h) {
    translate([x, y, 0]) cylinder(d=d, h=h, center=true);
}

module add_block(x, y, z0, sx, sy, sz) {
    // z0 is the bottom Z of the block; block overlaps into whatever is below by ov
    translate([x, y, z0 + sz/2 - ov])
        cube([sx, sy, sz], center=true);
}

module add_cyl(x, y, z0, d, h) {
    translate([x, y, z0 + h/2 - ov])
        cylinder(d=d, h=h, center=true);
}

module edge_connector(side="right", y=0, w=14, depth=9, h=9) {
    // Attached to PCB edge with overlap
    x = (side=="right")
        ? (pcb_length/2 + depth/2 - ov)
        : (-pcb_length/2 - depth/2 + ov);

    add_block(x, y, pcb_thickness/2, depth, w, h);
}

module bottom_edge_connector(x=0, depth=7, w=12, h=4.5) {
    // Attached to -Y edge
    y = -(pcb_width/2 + depth/2 - ov);
    add_block(x, y, pcb_thickness/2, w, depth, h);
}

module header_pins(x, y, n=10, pitch=2.54, pin_d=1.2, pin_h=6) {
    for (i = [0:n-1]) {
        yy = y + (i-(n-1)/2)*pitch;
        add_cyl(x, yy, pcb_thickness/2, pin_d, pin_h);
    }
}

module chip(x, y, sx, sy, h) {
    add_block(x, y, pcb_thickness/2, sx, sy, h);
}

module electrolytic_cap(x, y, d=6.5, h=10) {
    add_cyl(x, y, pcb_thickness/2, d, h);
}

module inductor(x, y, sx=10, sy=10, h=5) {
    add_block(x, y, pcb_thickness/2, sx, sy, h);
}

module screw_post_ring(x, y, outer_d=6.5, inner_d=3.2, h=3.0) {
    // Ring standoff around mounting hole; connected to PCB top
    difference() {
        add_cyl(x, y, pcb_thickness/2, outer_d, h);
        translate([x, y, pcb_thickness/2 + h/2 - ov])
            cylinder(d=inner_d, h=h + 2*ov, center=true);
    }
}

// ---------- Mainboard ----------
module printer_mainboard() {

    // Mounting hole pattern (near corners)
    hole_d = 3.2;
    hole_inset_x = 5.0;
    hole_inset_y = 5.0;
    hx = pcb_length/2 - hole_inset_x;
    hy = pcb_width/2  - hole_inset_y;

    // Board corner radius
    corner_r = 2.0;

    union() {
        // PCB with holes
        difference() {
            pcb_body(pcb_length, pcb_width, pcb_thickness, corner_r);

            for (sx = [-1, 1], sy = [-1, 1])
                cut_hole(sx*hx, sy*hy, hole_d, pcb_thickness + 2);
        }

        // Standoff rings around holes (keeps one connected solid)
        post_outer_d = 6.5;
        post_h = 3.0;
        for (sx = [-1, 1], sy = [-1, 1])
            screw_post_ring(sx*hx, sy*hy, post_outer_d, hole_d, post_h);

        // --- Components (top side) ---
        // Main MCU
        chip(0, 0, 18, 18, 2.2);

        // Stepper driver modules (3)
        driver_h  = 2.0;
        driver_sx = 10;
        driver_sy = 12;
        driver_x  = -pcb_length/2 + 18;
        driver_pitch = 12.5;
        for (k = [-1, 0, 1])
            chip(driver_x, k*driver_pitch, driver_sx, driver_sy, driver_h);

        // Power section: inductor + caps
        inductor(pcb_length/2 - 20, pcb_width/2 - 10, 12, 10, 4.5);
        electrolytic_cap(pcb_length/2 - 33, pcb_width/2 - 10, d=7.5, h=10);

        // Small SMD blocks to add "PCB populated" look
        chip(pcb_length/2 - 30, 0, 8, 6, 1.6);
        chip(pcb_length/2 - 42, -8, 6, 6, 1.4);
        chip(-10, pcb_width/2 - 9, 10, 6, 1.6);

        // Edge connectors (right side)
        edge_connector("right", y=0,               w=14, depth=9, h=9);
        edge_connector("right", y=pcb_width/2-9,   w=10, depth=7, h=7);

        // Edge connector (left side)
        edge_connector("left",  y=-(pcb_width/2-9), w=10, depth=7, h=7);

        // Bottom edge USB-like connector
        bottom_edge_connector(x=pcb_length/2 - 12, depth=7, w=12, h=4.5);

        // Pin header row near bottom edge
        header_pins(x=0, y=-(pcb_width/2 - 6), n=10, pitch=2.54, pin_d=1.2, pin_h=6);

        // --- Bottom-side features (kept connected by overlap into PCB) ---
        // A couple of underside ICs / regulators
        add_block(-pcb_length/2 + 22, 0, -pcb_thickness/2, 10, 8, 1.8);
        add_block( pcb_length/2 - 26, -6, -pcb_thickness/2, 12, 8, 2.0);
    }
}

printer_mainboard();