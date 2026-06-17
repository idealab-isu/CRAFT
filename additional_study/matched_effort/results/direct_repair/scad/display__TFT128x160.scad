$fn = 64;

// LCD TFT Display Module 128x160
// Overall PCB: 46.0mm x 34.0mm
// Simple representative model: PCB + bezel + active display area + header pads

module lcd_tft_128x160_module(
    pcb_x = 46.0,
    pcb_y = 34.0,
    pcb_t = 1.6,

    // Display window / bezel region (approximate)
    bezel_x = 36.0,
    bezel_y = 28.0,
    bezel_t = 2.2,
    bezel_z_gap = 0.2,   // small gap above PCB

    // Active area (approximate for 1.8" 128x160)
    active_x = 28.0,
    active_y = 35.0 * 0.0 + 22.0, // keep explicit numeric; 22mm typical visible height
    active_t = 0.6,

    // Header (typical 1x8 2.54mm)
    header_pins = 8,
    header_pitch = 2.54,
    header_pad_d = 1.6,
    header_pad_h = 0.15,
    header_row_offset_y = 3.0, // distance from PCB bottom edge to pad centers
    header_center_x = 0.0
) {
    // Colors
    pcb_col   = [0.05, 0.35, 0.12];
    bezel_col = [0.05, 0.05, 0.05];
    glass_col = [0.10, 0.10, 0.12, 0.85];
    pad_col   = [0.85, 0.70, 0.20];

    // PCB
    color(pcb_col)
        translate([-pcb_x/2, -pcb_y/2, 0])
            cube([pcb_x, pcb_y, pcb_t], center=false);

    // Bezel (a raised frame with a cutout)
    translate([0, 0, pcb_t + bezel_z_gap]) {
        color(bezel_col)
        difference() {
            translate([-bezel_x/2, -bezel_y/2, 0])
                cube([bezel_x, bezel_y, bezel_t], center=false);

            // Cutout for active area (slightly larger than active)
            cut_x = active_x + 2.0;
            cut_y = active_y + 2.0;
            translate([-cut_x/2, -cut_y/2, -0.1])
                cube([cut_x, cut_y, bezel_t + 0.2], center=false);
        }

        // Active display "glass"
        color(glass_col)
            translate([-active_x/2, -active_y/2, 0.2])
                cube([active_x, active_y, active_t], center=false);
    }

    // Header pads along bottom edge (approximate)
    // Place centered on X unless overridden
    pads_span = (header_pins - 1) * header_pitch;
    x0 = header_center_x - pads_span/2;
    y_pad = -pcb_y/2 + header_row_offset_y;

    for (i = [0:header_pins-1]) {
        color(pad_col)
            translate([x0 + i*header_pitch, y_pad, pcb_t])
                cylinder(d=header_pad_d, h=header_pad_h, center=false);
    }
}

lcd_tft_128x160_module();