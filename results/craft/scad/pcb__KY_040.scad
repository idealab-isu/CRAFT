$fn = 64;

// Rotary encoder breakout PCB (board only): 26.3mm x 19.5mm x 1.6mm
// ONE connected solid, no floating parts, no encoder/shaft component geometry.

// ---------------- Parameters ----------------
pcb_L = 26.3;
pcb_W = 19.5;
pcb_T = 1.6;

corner_r = 2.0;

// Typical breakout mounting holes (2x)
mount_hole_d = 3.0;
mount_hole_edge_x = 2.5;
mount_hole_edge_y = 2.5;

// Header pads (5x) along one edge
pad_count = 5;
pad_pitch = 2.54;
pad_d = 1.6;
pad_hole_d = 1.0;
pad_edge_offset = 2.0;

// Layer thicknesses (visual only; still one solid via overlap)
copper_T = 0.035;
mask_T   = 0.02;
silk_T   = 0.02;

silk_line_w = 0.4;
mask_clearance = 0.2;

trace_w = 0.5;
trace_len = 8.0;

overlap = 0.6; // ensures all added features intersect PCB (one connected solid)

// ---------------- Helpers ----------------
module rounded_rect_prism(L, W, H, r) {
    linear_extrude(height=H, center=true)
        offset(r=r)
            square([L-2*r, W-2*r], center=true);
}

module pcb_solid() {
    rounded_rect_prism(pcb_L, pcb_W, pcb_T, corner_r);
}

module mount_holes_cut_2x() {
    // Two mounting holes near the top corners (common breakout style)
    y = pcb_W/2 - mount_hole_edge_y;
    for (sx = [-1, 1]) {
        x = sx*(pcb_L/2 - mount_hole_edge_x);
        translate([x, y, 0])
            cylinder(d=mount_hole_d, h=pcb_T + 4*overlap, center=true);
    }
}

module header_pad_holes_cut() {
    // 5 pads along bottom edge
    y = -pcb_W/2 + pad_edge_offset;
    for (i = [0:pad_count-1]) {
        x = -((pad_count-1)*pad_pitch)/2 + i*pad_pitch;
        translate([x, y, 0])
            cylinder(d=pad_hole_d, h=pcb_T + 4*overlap, center=true);
    }
}

module copper_pads_and_traces_solid() {
    // Copper overlaps into PCB so it is one connected solid
    zc = pcb_T/2 + copper_T/2 - overlap;

    union() {
        y = -pcb_W/2 + pad_edge_offset;

        for (i = [0:pad_count-1]) {
            x = -((pad_count-1)*pad_pitch)/2 + i*pad_pitch;

            // pad
            translate([x, y, zc])
                cylinder(d=pad_d, h=copper_T + 2*overlap, center=true);

            // trace inward (toward board center)
            // Start at pad and extend toward +Y by trace_len
            translate([x, y + trace_len/2 - overlap, zc])
                cube([trace_w, trace_len, copper_T + 2*overlap], center=true);
        }
    }
}

module solder_mask_solid_with_openings() {
    // Mask sheet overlaps into PCB; openings are cut out
    zm = pcb_T/2 + mask_T/2 - overlap;

    difference() {
        translate([0, 0, zm])
            rounded_rect_prism(pcb_L, pcb_W, mask_T + 2*overlap, corner_r);

        // openings over header pads
        y = -pcb_W/2 + pad_edge_offset;
        for (i = [0:pad_count-1]) {
            x = -((pad_count-1)*pad_pitch)/2 + i*pad_pitch;
            translate([x, y, zm])
                cylinder(d=pad_d + 2*mask_clearance, h=mask_T + 6*overlap, center=true);
        }
    }
}

module silkscreen_outline_solid() {
    // Simple silkscreen border on top; overlaps into PCB
    zs = pcb_T/2 + silk_T/2 - overlap;

    union() {
        // top/bottom lines
        translate([0, pcb_W/2 - silk_line_w/2, zs])
            cube([pcb_L - 2*silk_line_w, silk_line_w, silk_T + 2*overlap], center=true);
        translate([0, -pcb_W/2 + silk_line_w/2, zs])
            cube([pcb_L - 2*silk_line_w, silk_line_w, silk_T + 2*overlap], center=true);

        // left/right lines
        translate([-pcb_L/2 + silk_line_w/2, 0, zs])
            cube([silk_line_w, pcb_W - 2*silk_line_w, silk_T + 2*overlap], center=true);
        translate([pcb_L/2 - silk_line_w/2, 0, zs])
            cube([silk_line_w, pcb_W - 2*silk_line_w, silk_T + 2*overlap], center=true);
    }
}

// ---------------- Final: ONE connected solid ----------------
module complete_model_one_solid() {
    union() {
        // PCB with holes (through cuts)
        difference() {
            pcb_solid();
            mount_holes_cut_2x();
            header_pad_holes_cut();
        }

        // Top layers (overlapping into PCB so everything is one connected solid)
        copper_pads_and_traces_solid();
        solder_mask_solid_with_openings();
        silkscreen_outline_solid();
    }
}

complete_model_one_solid();