$fn = 64;

// Target board dimensions (must match request)
pcb_L = 68.58;
pcb_W = 53.34;
pcb_T = 1.6;

// Board geometry
corner_R = 3.0;

// Mounting holes
hole_d = 3.2;
hole_edge_offset = 4.0;
hole_clearance_z = 0.8;   // ensure clean through-cut

// Small overlap to guarantee connectivity between touching solids
attach_overlap = 0.25;

// Silkscreen (very thin so it doesn't look like a thick slab)
silk_T = 0.12;
silk_margin = 1.2;

// Recognizable dev-board features (simplified)
header_L = pcb_L - 2*(hole_edge_offset + 3.0); // long header run inside mounting holes
header_W = 5.0;
header_H = 3.2;                                // low profile so PCB thickness reads correctly
header_edge_inset = 1.6;

pin_pitch = 2.54;
pin_r = 0.55;
pin_h = 2.2;

usb_L = 8.0;
usb_W = 7.6;
usb_H = 3.2;
usb_edge_overhang = 1.2;

mcu_L = 14.0;
mcu_W = 14.0;
mcu_H = 1.4;

reg_L = 6.0;
reg_W = 5.0;
reg_H = 1.2;

cap_r = 2.0;
cap_h = 2.6;

led_r = 1.0;
led_h = 1.0;

button_L = 6.0;
button_W = 6.0;
button_H = 2.6;

// Helpers
module rounded_rect_prism(L, W, T, R) {
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(L/2 - R), sy*(W/2 - R), 0])
                cylinder(r=R, h=T, center=true);
    }
}

module pcb_body() {
    rounded_rect_prism(pcb_L, pcb_W, pcb_T, corner_R);
}

module mounting_holes() {
    for (sx = [-1, 1], sy = [-1, 1])
        translate([sx*(pcb_L/2 - hole_edge_offset),
                   sy*(pcb_W/2 - hole_edge_offset),
                   0])
            cylinder(r=hole_d/2, h=pcb_T + hole_clearance_z, center=true);
}

module silkscreen_markings() {
    // Thin silkscreen on top, slightly overlapping into PCB
    translate([0, 0, pcb_T/2 + silk_T/2 - attach_overlap])
        cube([pcb_L - 2*silk_margin, pcb_W - 2*silk_margin, silk_T], center=true);
}

module header_with_pins(y_pos) {
    // Header body
    z_hdr = pcb_T/2 + header_H/2 - attach_overlap;
    translate([0, y_pos, z_hdr])
        cube([header_L, header_W, header_H], center=true);

    // Pin row (small cylinders) to read as pin headers; overlap into header body
    n_pins = floor(header_L / pin_pitch);
    x0 = -( (n_pins-1) * pin_pitch )/2;
    z_pin = pcb_T/2 + header_H - attach_overlap + pin_h/2 - attach_overlap;

    for (i = [0:n_pins-1]) {
        translate([x0 + i*pin_pitch, y_pos, z_pin])
            cylinder(r=pin_r, h=pin_h, center=true);
    }
}

module connectors_and_components() {
    // Z placements (all overlap into PCB so everything is one connected solid)
    z_usb = pcb_T/2 + usb_H/2 - attach_overlap;
    z_mcu = pcb_T/2 + mcu_H/2 - attach_overlap;
    z_reg = pcb_T/2 + reg_H/2 - attach_overlap;
    z_cap = pcb_T/2 + cap_h/2 - attach_overlap;
    z_led = pcb_T/2 + led_h/2 - attach_overlap;
    z_btn = pcb_T/2 + button_H/2 - attach_overlap;

    // Two long pin headers along the long edges
    y_hdr_bot = -pcb_W/2 + header_edge_inset + header_W/2;
    y_hdr_top =  pcb_W/2 - header_edge_inset - header_W/2;
    header_with_pins(y_hdr_bot);
    header_with_pins(y_hdr_top);

    // USB connector on right edge, protruding outward but still connected via overlap into PCB
    // Center X is set so inner face overlaps into board by attach_overlap
    x_usb = pcb_L/2 - usb_L/2 + usb_edge_overhang;
    translate([x_usb, 0, z_usb])
        cube([usb_L, usb_W, usb_H], center=true);

    // Main MCU package near center-left
    x_mcu = -pcb_L/2 + hole_edge_offset + 10 + mcu_L/2;
    translate([x_mcu, 0, z_mcu])
        cube([mcu_L, mcu_W, mcu_H], center=true);

    // Small regulator near USB (inside board)
    x_reg = pcb_L/2 - hole_edge_offset - 10 - reg_L/2;
    y_reg = pcb_W/2 - hole_edge_offset - 10 - reg_W/2;
    translate([x_reg, y_reg, z_reg])
        cube([reg_L, reg_W, reg_H], center=true);

    // Capacitor near regulator
    x_cap = x_reg - (reg_L/2 + cap_r + 2.0);
    y_cap = y_reg;
    translate([x_cap, y_cap, z_cap])
        cylinder(r=cap_r, h=cap_h, center=true);

    // Two LEDs near bottom-right
    led_x = pcb_L/2 - hole_edge_offset - 2.5*led_r;
    led_y0 = -pcb_W/2 + hole_edge_offset + 2.5*led_r;
    translate([led_x, led_y0, z_led])
        cylinder(r=led_r, h=led_h, center=true);
    translate([led_x, led_y0 + 4.0*led_r, z_led])
        cylinder(r=led_r, h=led_h, center=true);

    // Reset button near top-left
    x_btn = -pcb_L/2 + hole_edge_offset + 8 + button_L/2;
    y_btn =  pcb_W/2 - hole_edge_offset - 8 - button_W/2;
    translate([x_btn, y_btn, z_btn])
        cube([button_L, button_W, button_H], center=true);

    // Bottom-side "solder blobs"/pads under headers to make bottom view look like a dev board,
    // kept thin so it doesn't read as a thick block; overlap into PCB for connectivity.
    pad_T = 0.25;
    pad_inset = 2.0;
    pad_L = header_L;
    pad_W = header_W + 1.2;

    z_pad = -pcb_T/2 - pad_T/2 + attach_overlap; // overlaps into PCB from below
    translate([0, y_hdr_bot, z_pad])
        cube([pad_L, pad_W, pad_T], center=true);
    translate([0, y_hdr_top, z_pad])
        cube([pad_L, pad_W, pad_T], center=true);

    // Small bottom pad near USB area
    usb_pad_L = 10.0;
    usb_pad_W = 9.0;
    translate([pcb_L/2 - hole_edge_offset - usb_pad_L/2 - pad_inset,
               0,
               z_pad])
        cube([usb_pad_L, usb_pad_W, pad_T], center=true);
}

// Final Assembly: one connected solid with holes subtracted
difference() {
    union() {
        pcb_body();
        silkscreen_markings();
        connectors_and_components();
    }
    mounting_holes();
}