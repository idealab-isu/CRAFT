$fn = 64;

// Board overall dimensions (mm)
pcb_length = 203.2;
pcb_width  = 49.53;
pcb_thickness = 1.6;

// Small overlap to guarantee watertight unions
overlap = 0.2;

// ---------- Helpers ----------
module rounded_box(size=[10,10,2], r=1, center=true) {
    // Minkowski rounded rectangle prism
    // size is final outer size
    sx = size[0]; sy = size[1]; sz = size[2];
    rr = min(r, min(sx,sy)/2 - 0.01);
    translate(center ? [0,0,0] : [sx/2, sy/2, sz/2])
        minkowski() {
            cube([sx-2*rr, sy-2*rr, sz], center=true);
            cylinder(r=rr, h=0.01, center=true);
        }
}

module pcb_with_holes() {
    // Typical mounting holes (4x) near corners
    hole_d = 3.2;
    edge_x = 6.0;
    edge_y = 6.0;

    difference() {
        // PCB slab
        cube([pcb_length, pcb_width, pcb_thickness], center=true);

        // Through holes
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([
                sx*(pcb_length/2 - edge_x),
                sy*(pcb_width/2  - edge_y),
                0
            ])
            cylinder(d=hole_d, h=pcb_thickness + 2, center=true);
        }
    }
}

// ---------- Features (all connected to PCB) ----------
module usb_connector() {
    // Simple USB-B style block on one long edge
    conn_w = 12.0;   // along Y
    conn_l = 16.0;   // along X
    conn_h = 11.0;   // above PCB

    // Place so it sits on top of PCB and touches the +Y edge
    translate([
        -pcb_length/2 + conn_l/2 + 18,                                  // offset from left end
        pcb_width/2 + conn_w/2 - overlap,                               // overlap into PCB edge
        pcb_thickness/2 + conn_h/2 - overlap                            // overlap into PCB top
    ])
    rounded_box([conn_l, conn_w, conn_h], r=1.2, center=true);
}

module power_terminal() {
    // Screw terminal block on long edge
    term_l = 20.0;  // along X
    term_w = 12.0;  // along Y
    term_h = 14.0;  // above PCB

    translate([
        pcb_length/2 - term_l/2 - 18,                                   // near right end
        pcb_width/2 + term_w/2 - overlap,                               // overlap into PCB edge
        pcb_thickness/2 + term_h/2 - overlap
    ])
    rounded_box([term_l, term_w, term_h], r=1.2, center=true);
}

module pin_header_row(n=10, pitch=2.54) {
    // Simple header body (not individual pins) on the opposite long edge
    body_l = n * pitch + 2.0;  // along X
    body_w = 6.0;              // along Y
    body_h = 8.0;              // above PCB

    translate([
        0,
        -pcb_width/2 - body_w/2 + overlap,                              // overlap into -Y edge
        pcb_thickness/2 + body_h/2 - overlap
    ])
    rounded_box([body_l, body_w, body_h], r=0.8, center=true);
}

module stepper_driver_blocks() {
    // A few raised component blocks on top surface
    blk1 = [18, 15, 6];
    blk2 = [22, 18, 7];
    blk3 = [16, 14, 5];

    // All placed on top with slight overlap into PCB
    translate([
        -pcb_length/2 + 55,
        0,
        pcb_thickness/2 + blk1[2]/2 - overlap
    ])
    rounded_box(blk1, r=1.0, center=true);

    translate([
        -pcb_length/2 + 95,
        0,
        pcb_thickness/2 + blk2[2]/2 - overlap
    ])
    rounded_box(blk2, r=1.0, center=true);

    translate([
        -pcb_length/2 + 130,
        0,
        pcb_thickness/2 + blk3[2]/2 - overlap
    ])
    rounded_box(blk3, r=1.0, center=true);
}

module heatsink_like_block() {
    // A finned block (single connected solid) on top
    base_l = 28;
    base_w = 22;
    base_h = 6;

    fin_count = 6;
    fin_t = 1.2;
    fin_gap = (base_l - fin_count*fin_t) / (fin_count+1);
    fin_h = 6;

    union() {
        translate([
            pcb_length/2 - 70,
            -8,
            pcb_thickness/2 + base_h/2 - overlap
        ])
        rounded_box([base_l, base_w, base_h], r=1.0, center=true);

        // Fins protruding upward from base, overlapping into base
        for (i = [0:fin_count-1]) {
            x0 = -base_l/2 + fin_gap*(i+1) + fin_t*(i+0.5);
            translate([
                pcb_length/2 - 70 + x0,
                -8,
                pcb_thickness/2 + base_h + fin_h/2 - overlap
            ])
            cube([fin_t, base_w-4, fin_h], center=true);
        }
    }
}

// ---------- Assembly ----------
union() {
    pcb_with_holes();
    usb_connector();
    power_terminal();
    pin_header_row(n=18, pitch=2.54);
    stepper_driver_blocks();
    heatsink_like_block();
}