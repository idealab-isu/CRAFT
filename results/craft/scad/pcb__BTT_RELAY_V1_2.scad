$fn = 64;

// Parameters (mm)
length_mm = 80.4;      // X
width_mm  = 36.3;      // Y
thickness_mm = 1.5;    // Z
corner_radius_mm = 2.0;

// Overlap to guarantee one connected solid (1–2mm as required)
overlap = 1.2;

// ---------- Helpers ----------
module rounded_plate_xy(l, w, h, r) {
    r2 = min(r, min(l, w)/2);
    linear_extrude(height=h, center=true)
        offset(r=r2)
            square([l-2*r2, w-2*r2], center=true);
}

module box_center(sz=[1,1,1]) { cube(sz, center=true); }

// ---------- Mainboard-like geometry ----------
module BTT_RELAY_V1_2_like() {

    // Mounting hole pattern (typical 4-corner)
    hole_d = 3.2;
    hole_edge_x = 3.5;
    hole_edge_y = 3.5;

    hx = length_mm/2 - hole_edge_x;
    hy = width_mm/2  - hole_edge_y;

    // Component heights
    comp_h_low  = 2.0;
    comp_h_mid  = 4.0;

    // Connector sizes
    term_w = 10.0;  // along X
    term_d = 9.0;   // along Y
    term_h = 10.0;  // along Z

    header_w = 18.0;
    header_d = 6.0;
    header_h = 6.0;

    relay_w = 28.0;
    relay_d = 15.0;
    relay_h = 12.0;

    // Placement formulas
    pcb_top_z = thickness_mm/2;
    pcb_bot_z = -thickness_mm/2;

    // Edge-attached connector centers (overlap into PCB by 'overlap')
    term_y   =  width_mm/2 + term_d/2 - overlap;   // top edge
    header_y = -width_mm/2 - header_d/2 + overlap; // bottom edge

    // Keep within board length with margins
    margin_x = 6.0;

    // Terminal blocks near top edge
    term1_x = -length_mm/2 + margin_x + term_w/2;
    term2_x =  length_mm/2 - margin_x - term_w/2;

    // Header near bottom edge, centered
    header_x = 0;

    // Relay centered-ish
    relay_x = 0;
    relay_y = 0;

    // Small components (caps/resistors) on top
    cap_r = 3.0;
    cap_h = 7.0;

    cap1_x = -length_mm/2 + 18.0;
    cap2_x =  length_mm/2 - 18.0;

    // IC block
    ic_w = 14.0;
    ic_d = 10.0;
    ic_h = 3.0;
    ic_x = 0;
    ic_y = -6.0;

    // USB-like connector on right edge (stylized)
    usb_w = 12.0; // along X
    usb_d = 10.0; // along Y
    usb_h = 5.0;  // along Z
    usb_x = length_mm/2 + usb_w/2 - overlap; // right edge overlap into PCB
    usb_y = -6.0;

    // Additional edge connector blocks (to match "protruding from PCB edges top/bottom/left/right")
    edge_blk_w = 12.0;
    edge_blk_d = 8.0;
    edge_blk_h = 8.0;

    // Left/right edge blocks (overlap into PCB by 'overlap')
    left_blk_x  = -length_mm/2 - edge_blk_w/2 + overlap;
    right_blk_x =  length_mm/2 + edge_blk_w/2 - overlap;

    // Top/bottom edge blocks (overlap into PCB by 'overlap')
    top_blk_y    =  width_mm/2 + edge_blk_d/2 - overlap;
    bottom_blk_y = -width_mm/2 - edge_blk_d/2 + overlap;

    // Z placement: ensure every component intersects PCB by 'overlap'
    // Component center Z so bottom sits at (pcb_top_z - overlap)
    function z_on_top(h) = pcb_top_z + h/2 - overlap;
    // Bottom pads: top sits at (pcb_bot_z + overlap)
    function z_on_bottom(h) = pcb_bot_z - h/2 + overlap;

    union() {
        // PCB with mounting holes
        color([0.0, 0.4, 0.2])
        difference() {
            rounded_plate_xy(length_mm, width_mm, thickness_mm, corner_radius_mm);

            for (sx = [-1, 1], sy = [-1, 1])
                translate([sx*hx, sy*hy, 0])
                    cylinder(d=hole_d, h=thickness_mm + 2*overlap, center=true);
        }

        // Terminal blocks (top edge) - fused via overlap
        color([0.15, 0.15, 0.15])
        for (tx = [term1_x, term2_x])
            translate([tx, term_y, z_on_top(term_h)])
                box_center([term_w, term_d, term_h]);

        // Pin header (bottom edge) - fused via overlap
        color([0.1, 0.1, 0.1])
        translate([header_x, header_y, z_on_top(header_h)])
            box_center([header_w, header_d, header_h]);

        // Relay block (center) - fused via overlap
        color([0.05, 0.05, 0.05])
        translate([relay_x, relay_y, z_on_top(relay_h)])
            box_center([relay_w, relay_d, relay_h]);

        // USB-like connector (right edge) - fused via overlap
        color([0.2, 0.2, 0.2])
        translate([usb_x, usb_y, z_on_top(usb_h)])
            box_center([usb_w, usb_d, usb_h]);

        // Edge connector/component blocks protruding from PCB edges (top/bottom/left/right)
        // These were the "floating/separate bodies" in the views; ensure they overlap into PCB.
        color([0.08, 0.08, 0.08]) {
            // Top edge blocks (left/right-ish)
            for (xpos = [-length_mm/4, length_mm/4])
                translate([xpos, top_blk_y, z_on_top(edge_blk_h)])
                    box_center([edge_blk_w, edge_blk_d, edge_blk_h]);

            // Bottom edge block (center)
            translate([0, bottom_blk_y, z_on_top(edge_blk_h)])
                box_center([edge_blk_w, edge_blk_d, edge_blk_h]);

            // Left edge block (lower half)
            translate([left_blk_x, -width_mm/4, z_on_top(edge_blk_h)])
                box_center([edge_blk_w, edge_blk_d, edge_blk_h]);

            // Right edge block (upper half) (USB is also on right; keep separate but fused)
            translate([right_blk_x, width_mm/4, z_on_top(edge_blk_h)])
                box_center([edge_blk_w, edge_blk_d, edge_blk_h]);
        }

        // Capacitors (cylinders) - fused via overlap
        color([0.2, 0.2, 0.2])
        for (cx = [cap1_x, cap2_x])
            translate([cx, 0, z_on_top(cap_h)])
                cylinder(r=cap_r, h=cap_h, center=true);

        // IC block - fused via overlap
        color([0.12, 0.12, 0.12])
        translate([ic_x, ic_y, z_on_top(ic_h)])
            box_center([ic_w, ic_d, ic_h]);

        // Low-profile components - fused via overlap
        color([0.18, 0.18, 0.18])
        for (p = [
            [-20,  10, comp_h_low, 10, 4],
            [ 20,  10, comp_h_low, 10, 4],
            [-10, -12, comp_h_mid,  8, 5],
            [ 10, -12, comp_h_mid,  8, 5]
        ]) {
            translate([p[0], p[1], z_on_top(p[2])])
                box_center([p[3], p[4], p[2]]);
        }

        // Bottom-side standoffs/pads - fused via overlap into PCB
        pad_w = 8;
        pad_d = 6;
        pad_h = 1.2;
        color([0.25, 0.25, 0.25])
        for (sx = [-1, 1]) {
            translate([sx*(length_mm/2 - 14), 0, z_on_bottom(pad_h)])
                box_center([pad_w, pad_d, pad_h]);
        }
    }
}

// PCB - Mainboard
module pcb() {
    BTT_RELAY_V1_2_like();
}

// Assembly
module assembly() {
    pcb();
}

assembly();