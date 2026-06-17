$fn = 64;

// LCD TFT Display Module 128x160
// Overall PCB: 46.0mm x 34.0mm
// Single connected solid (union of all parts). No floating geometry.
// Holes are modeled as shallow recesses (not through-cuts) to keep one solid.

module lcd_tft_128x160_module(
    pcb_x = 46.0,
    pcb_y = 34.0,
    pcb_t = 1.6,

    // Bezel/frame on top of PCB
    bezel_x = 36.0,
    bezel_y = 28.0,
    bezel_t = 2.2,

    // Active screen (glass) on top of bezel
    screen_x = 28.0,
    screen_y = 35.0,   // portrait-ish active area representation
    screen_t = 0.8,

    // Header pads + connector body along one long edge
    header_pins = 14,
    header_pitch = 2.54,
    header_pad_d = 1.6,
    header_pad_h = 0.25,

    conn_y = 5.0,
    conn_z = 3.0,

    // FPC tail (thin flex) extending from connector edge
    fpc_w = 12.0,
    fpc_len = 10.0,
    fpc_t = 0.2
) {
    eps = 0.2; // small overlap to guarantee connectivity

    // Derived placement
    pad_span = (header_pins - 1) * header_pitch;
    conn_x = pad_span + 4.0;

    // Place connector near -Y edge, fully on PCB
    edge_margin = 1.2;
    conn_center_y = -pcb_y/2 + edge_margin + conn_y/2;

    // Z stacking (all connected with slight overlaps)
    pcb_z0 = 0;
    pcb_z1 = pcb_t;

    bezel_center_z = pcb_z1 + bezel_t/2 - eps/2;
    screen_center_z = (pcb_z1 + bezel_t) + screen_t/2 - eps/2;

    // Header pads sit on PCB top, slightly overlapping into PCB
    pad_z0 = pcb_z1 - eps;
    pad_h = header_pad_h + eps;

    // Connector body sits on PCB top, overlaps into PCB
    conn_center_z = pcb_z1 + conn_z/2 - eps/2;

    // FPC tail extends outward from connector toward -Y, attached to connector top
    fpc_center_x = 0;
    fpc_center_y = (conn_center_y - conn_y/2) - fpc_len/2 + eps/2; // overlap into connector
    fpc_center_z = (pcb_z1 + conn_z) - fpc_t/2 + eps/2;            // overlap into connector

    // Mounting hole recesses (shallow dimples) to keep one solid
    hole_d = 2.6;
    hole_off = 3.0;
    hole_recess = 0.6; // depth from top surface

    // Screen clamp tabs (light gray) like reference images: two blocks at connector edge
    tab_x = 6.0;
    tab_y = conn_y;
    tab_z = conn_z;
    tab_center_z = conn_center_z;
    tab_center_y = conn_center_y;

    tab_center_x_left  = -bezel_x/2 + tab_x/2 + 1.0;
    tab_center_x_right =  bezel_x/2 - tab_x/2 - 1.0;

    union() {
        // PCB with shallow recesses for mounting holes
        color([0.05, 0.35, 0.12])
        difference() {
            translate([-pcb_x/2, -pcb_y/2, pcb_z0])
                cube([pcb_x, pcb_y, pcb_t], center=false);

            // recess from top only (does not cut through)
            for (sx = [-1, 1], sy = [-1, 1]) {
                translate([sx*(pcb_x/2 - hole_off), sy*(pcb_y/2 - hole_off), pcb_z1 - hole_recess])
                    cylinder(d=hole_d, h=hole_recess + 0.05, center=false);
            }
        }

        // Bezel/frame (centered)
        color([0.08, 0.08, 0.08])
        translate([0, 0, bezel_center_z])
            cube([bezel_x, bezel_y, bezel_t], center=true);

        // Active screen area (clamped to bezel footprint)
        screen_y_eff = min(screen_y, bezel_y - 2);
        color([0.02, 0.02, 0.02])
        translate([0, 0, screen_center_z])
            cube([screen_x, screen_y_eff, screen_t], center=true);

        // Header pads along connector edge (near -Y)
        color([0.85, 0.7, 0.2])
        for (i = [0:header_pins-1]) {
            x = -pad_span/2 + i*header_pitch;
            translate([x, conn_center_y, pad_z0])
                cylinder(d=header_pad_d, h=pad_h, center=false);
        }

        // Connector body (white/gray), attached to PCB
        color([0.9, 0.9, 0.9])
        translate([0, conn_center_y, conn_center_z])
            cube([conn_x, conn_y, conn_z], center=true);

        // Two clamp tabs (light gray) at left/right ends of connector
        color([0.75, 0.75, 0.75])
        translate([tab_center_x_left, tab_center_y, tab_center_z])
            cube([tab_x, tab_y, tab_z], center=true);

        color([0.75, 0.75, 0.75])
        translate([tab_center_x_right, tab_center_y, tab_center_z])
            cube([tab_x, tab_y, tab_z], center=true);

        // FPC tail (thin flex) extending outward from connector edge
        color([0.85, 0.75, 0.35])
        translate([fpc_center_x, fpc_center_y, fpc_center_z])
            cube([fpc_w, fpc_len, fpc_t], center=true);
    }
}

lcd_tft_128x160_module();