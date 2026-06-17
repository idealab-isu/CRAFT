$fn = 48;

// Board dimensions (mm)
pcb_length    = 68.58;
pcb_width     = 53.34;
pcb_thickness = 1.6;

// Detail parameters (mm)
corner_r = 3.0;

// Mounting holes (typical dev-board style)
hole_r = 1.6;                 // ~3.2mm dia
hole_edge_x = 4.0;            // from left/right edge
hole_edge_y = 4.0;            // from bottom/top edge

// Component heights (mm)
soldermask_raise = 0.01;      // tiny overlap helper
chip_h   = 2.0;
usb_h    = 3.2;
header_h = 8.5;
cap_h    = 5.0;

// Helpers
module rounded_rect_2d(l, w, r) {
    // Robust rounded rectangle using hull of 4 circles
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(l/2 - r), sy*(w/2 - r)]) circle(r=r);
    }
}

module pcb_solid() {
    // Rounded PCB with mounting holes cut out
    difference() {
        linear_extrude(height=pcb_thickness, center=true)
            rounded_rect_2d(pcb_length, pcb_width, corner_r);

        // 4 mounting holes
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([ sx*(pcb_length/2 - hole_edge_x),
                        sy*(pcb_width/2  - hole_edge_y),
                        0 ])
                cylinder(h=pcb_thickness + 0.6, r=hole_r, center=true);
        }
    }
}

module chip_pkg(size_x, size_y, h) {
    // Simple IC package with slight corner rounding
    r = min(size_x, size_y) * 0.08;
    linear_extrude(height=h, center=true)
        hull() {
            for (sx = [-1, 1], sy = [-1, 1])
                translate([sx*(size_x/2 - r), sy*(size_y/2 - r)]) circle(r=r);
        }
}

module header_row(pins, pitch, pin_w, pin_d, body_h, pin_h) {
    // One connected solid: plastic body + pins fused into it
    row_len = (pins - 1) * pitch + pin_w;

    union() {
        // Plastic body
        translate([0, 0, body_h/2])
            cube([row_len, pin_d, body_h], center=true);

        // Pins (fused into body by overlap)
        for (i = [0 : pins-1]) {
            x = -row_len/2 + pin_w/2 + i*pitch;
            translate([x, 0, (pin_h/2) - 0.6])  // overlap into body
                cube([pin_w, pin_w, pin_h], center=true);
        }
    }
}

module usb_micro_port(w, d, h) {
    // Simple USB connector block (metal shell)
    r = min(w, d) * 0.12;
    linear_extrude(height=h, center=true)
        hull() {
            for (sx = [-1, 1], sy = [-1, 1])
                translate([sx*(w/2 - r), sy*(d/2 - r)]) circle(r=r);
        }
}

module dev_board() {
    union() {
        // PCB
        color([0.0, 0.4, 0.2])
            pcb_solid();

        // Components sit on top surface (z = +pcb_thickness/2)
        top_z = pcb_thickness/2;

        // Main MCU/SoC package (center-ish)
        color([0.15, 0.15, 0.15])
            translate([0, 0, top_z + chip_h/2 - soldermask_raise])
                chip_pkg(14, 14, chip_h);

        // USB connector on one short edge (protrudes outward but remains connected via overlap)
        usb_w = 8.0;
        usb_d = 7.0;
        color([0.75, 0.75, 0.78])
            translate([0,
                       pcb_width/2 - usb_d/2 + 0.8,                 // protrude out
                       top_z + usb_h/2 - soldermask_raise])         // sit on top
                usb_micro_port(usb_w, usb_d, usb_h);

        // Two header rows along the long edges
        pins = 20;
        pitch = 2.54;
        pin_w = 0.7;
        pin_d = 5.0;
        body_h = 2.5;
        pin_h  = header_h;

        // Left header
        color([0.05, 0.05, 0.05])
            translate([0,
                       -(pcb_width/2 - pin_d/2 - 1.0),              // near edge
                       top_z - soldermask_raise])                   // fuse into PCB
                header_row(pins, pitch, pin_w, pin_d, body_h, pin_h);

        // Right header
        color([0.05, 0.05, 0.05])
            translate([0,
                       (pcb_width/2 - pin_d/2 - 1.0),
                       top_z - soldermask_raise])
                header_row(pins, pitch, pin_w, pin_d, body_h, pin_h);

        // A couple of capacitors (simple cylinders) near USB
        cap_r = 2.0;
        color([0.2, 0.2, 0.2])
            for (dx = [-6, 6]) {
                translate([dx,
                           pcb_width/2 - 12,
                           top_z + cap_h/2 - soldermask_raise])
                    cylinder(h=cap_h, r=cap_r, center=true);
            }

        // Small regulator block
        reg_x = 6.0;
        reg_y = 4.0;
        reg_h = 1.8;
        color([0.12, 0.12, 0.12])
            translate([pcb_length/2 - 14,
                       pcb_width/2 - 14,
                       top_z + reg_h/2 - soldermask_raise])
                cube([reg_x, reg_y, reg_h], center=true);
    }
}

// Final output: one connected solid assembly
dev_board();