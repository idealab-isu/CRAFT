$fn = 64;

// Exact requested PCB dimensions
pcb_length = 68.58;
pcb_width  = 53.34;
pcb_thickness = 1.6;

// Feature parameters (generic dev board look)
corner_r = 3.0;                 // rounded corners
hole_r = 1.6;                   // ~3.2mm mounting holes
hole_edge_clear = 4.0;          // hole center offset from edges

overlap = 0.2;                  // ensures all added parts intersect PCB (one connected solid)

// Component heights (above PCB top)
usb_h = 3.2;
usb_w = 8.0;
usb_l = 7.0;

mcu_h = 1.2;
mcu_l = 14.0;
mcu_w = 14.0;

header_h = 8.5;
header_w = 2.6;

led_h = 1.2;
led_r = 1.0;

button_h = 2.0;
button_xy = 6.0;

// Helpers
module rounded_rect_prism(l, w, h, r) {
    // Minkowski gives rounded corners; keep r <= min(l,w)/2
    minkowski() {
        cube([l - 2*r, w - 2*r, h], center=true);
        cylinder(r=r, h=0.01, center=true);
    }
}

module pcb_body() {
    color([0.0, 0.4, 0.2])
    difference() {
        rounded_rect_prism(pcb_length, pcb_width, pcb_thickness, corner_r);

        // 4 mounting holes (through)
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([
                sx*(pcb_length/2 - hole_edge_clear),
                sy*(pcb_width/2  - hole_edge_clear),
                0
            ])
            cylinder(r=hole_r, h=pcb_thickness + 2, center=true);
        }
    }
}

module usb_connector() {
    // Place on +X edge, centered in Y, sitting on top of PCB with slight overlap
    translate([
        pcb_length/2 - usb_l/2 + overlap,
        0,
        pcb_thickness/2 + usb_h/2 - overlap
    ])
    color([0.75, 0.75, 0.75])
    cube([usb_l, usb_w, usb_h], center=true);
}

module mcu_chip() {
    // Center-ish on board
    translate([
        -pcb_length*0.08,
        0,
        pcb_thickness/2 + mcu_h/2 - overlap
    ])
    color([0.1, 0.1, 0.1])
    cube([mcu_l, mcu_w, mcu_h], center=true);
}

module header_strip(side = 1) {
    // side = +1 for +Y edge, -1 for -Y edge
    header_len = pcb_length - 2*6.0;
    translate([
        0,
        side*(pcb_width/2 - header_w/2 + overlap),
        pcb_thickness/2 + header_h/2 - overlap
    ])
    color([0.05, 0.05, 0.05])
    cube([header_len, header_w, header_h], center=true);
}

module led_indicator(xpos, ypos) {
    translate([
        xpos,
        ypos,
        pcb_thickness/2 + led_h/2 - overlap
    ])
    color([0.8, 0.1, 0.1])
    cylinder(r=led_r, h=led_h, center=true);
}

module reset_button() {
    // Near USB connector
    translate([
        pcb_length/2 - usb_l - button_xy/2 - 2.0,
        pcb_width*0.22,
        pcb_thickness/2 + button_h/2 - overlap
    ])
    color([0.2, 0.2, 0.2])
    cube([button_xy, button_xy, button_h], center=true);
}

module board_complete() {
    union() {
        pcb_body();

        // Components (all intersect PCB slightly to ensure one connected solid)
        usb_connector();
        mcu_chip();
        header_strip(+1);
        header_strip(-1);
        reset_button();

        // A couple LEDs
        led_indicator(pcb_length/2 - usb_l - 6.0, -pcb_width*0.22);
        led_indicator(pcb_length/2 - usb_l - 9.0, -pcb_width*0.22);
    }
}

board_complete();