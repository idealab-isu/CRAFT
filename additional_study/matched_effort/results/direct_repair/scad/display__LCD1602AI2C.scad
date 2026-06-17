$fn = 64;

// LCD 1602A display module (approx) 71.3mm x 24.3mm
// Simple renderable model: PCB + bezel/frame + display window + 16-pin header

module lcd1602a(
    pcb_x = 71.3,
    pcb_y = 24.3,
    pcb_t = 1.6,

    bezel_x = 66.0,
    bezel_y = 16.0,
    bezel_t = 3.2,
    bezel_z = 1.6,          // sits on top of PCB

    window_x = 56.0,
    window_y = 12.0,
    window_depth = 2.2,

    header_pins = 16,
    header_pitch = 2.54,
    header_pin_w = 0.64,
    header_pin_h = 6.0,
    header_body_h = 2.5,
    header_body_t = 2.5
) {
    // PCB
    color([0.05, 0.35, 0.12])
    translate([-pcb_x/2, -pcb_y/2, 0])
        cube([pcb_x, pcb_y, pcb_t], center=false);

    // Bezel/frame on top of PCB
    color([0.08, 0.08, 0.08])
    translate([0, 0, bezel_z])
    difference() {
        translate([-bezel_x/2, -bezel_y/2, 0])
            cube([bezel_x, bezel_y, bezel_t], center=false);

        // Window cutout
        translate([-window_x/2, -window_y/2, 0.6])
            cube([window_x, window_y, window_depth], center=false);
    }

    // Display glass (behind window)
    color([0.15, 0.25, 0.25, 0.85])
    translate([0, 0, bezel_z + 0.8])
        translate([-window_x/2 + 0.6, -window_y/2 + 0.6, 0])
            cube([window_x - 1.2, window_y - 1.2, 1.2], center=false);

    // 16-pin header along one long edge (typical)
    header_len = (header_pins - 1) * header_pitch;
    header_body_w = header_len + 2.0;
    header_body_d = header_body_t;

    // Place header near bottom edge of PCB
    header_y = -pcb_y/2 + 3.0;
    header_z = pcb_t;

    // Header plastic body
    color([0.05, 0.05, 0.05])
    translate([0, header_y, header_z])
        translate([-header_body_w/2, -header_body_d/2, 0])
            cube([header_body_w, header_body_d, header_body_h], center=false);

    // Pins
    color([0.75, 0.75, 0.78])
    for (i = [0:header_pins-1]) {
        x = -header_len/2 + i*header_pitch;
        translate([x, header_y, header_z])
            translate([-header_pin_w/2, -header_pin_w/2, -header_pin_h])
                cube([header_pin_w, header_pin_w, header_pin_h + header_body_h], center=false);
    }
}

lcd1602a();