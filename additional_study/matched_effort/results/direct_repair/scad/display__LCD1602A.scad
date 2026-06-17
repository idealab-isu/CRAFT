$fn = 64;

// LCD 1602A display module (approx) 71.3mm x 24.3mm
// Simple renderable model: PCB + bezel + viewing window + 16-pin header

module lcd1602a(
    pcb_x = 71.3,
    pcb_y = 24.3,
    pcb_t = 1.6,

    bezel_x = 64.5,
    bezel_y = 16.0,
    bezel_h = 3.2,

    window_x = 56.0,
    window_y = 12.0,
    window_depth = 1.2,

    header_pins = 16,
    header_pitch = 2.54,
    pin_d = 0.64,
    pin_h = 6.0,
    header_body_h = 2.5,
    header_body_t = 2.5
) {
    // Colors (optional; ignored by some exporters)
    pcb_col   = [0.05, 0.45, 0.15];
    bezel_col = [0.10, 0.10, 0.10];
    glass_col = [0.15, 0.25, 0.35, 0.6];
    metal_col = [0.75, 0.75, 0.78];

    // PCB
    color(pcb_col)
    translate([-pcb_x/2, -pcb_y/2, 0])
        cube([pcb_x, pcb_y, pcb_t], center=false);

    // Bezel + window recess
    color(bezel_col)
    translate([0, 0, pcb_t])
    difference() {
        translate([-bezel_x/2, -bezel_y/2, 0])
            cube([bezel_x, bezel_y, bezel_h], center=false);

        // Window cut
        translate([-window_x/2, -window_y/2, bezel_h - window_depth])
            cube([window_x, window_y, window_depth + 0.01], center=false);
    }

    // Glass in window
    color(glass_col)
    translate([0, 0, pcb_t + bezel_h - window_depth + 0.05])
        translate([-window_x/2, -window_y/2, 0])
            cube([window_x, window_y, window_depth - 0.1], center=false);

    // 16-pin header along one long edge (typical)
    header_len = (header_pins - 1) * header_pitch;
    header_x = header_len + header_pitch; // body slightly longer
    header_y = header_body_t;

    // Place header near bottom edge of PCB
    header_offset_y = -pcb_y/2 + 3.0;

    // Header plastic body
    color([0.05,0.05,0.05])
    translate([-header_x/2, header_offset_y - header_y/2, pcb_t])
        cube([header_x, header_y, header_body_h], center=false);

    // Pins
    color(metal_col)
    for (i = [0:header_pins-1]) {
        x = -header_len/2 + i*header_pitch;
        translate([x, header_offset_y, pcb_t])
            cylinder(d=pin_d, h=header_body_h + pin_h, center=false);
    }
}

lcd1602a();