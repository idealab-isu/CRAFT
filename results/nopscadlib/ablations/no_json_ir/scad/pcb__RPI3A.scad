$fn = 48;

// Target SBC overall PCB size (RECTANGLE ONLY)
pcb_l = 65.0;     // X
pcb_w = 56.0;     // Y
pcb_t = 1.4;      // Z

// Visual/feature parameters
corner_r = 3.0;

// Mounting holes
hole_d = 2.8;
hole_edge_x = 3.5;   // from left/right edge to hole center
hole_edge_y = 3.5;   // from bottom/top edge to hole center

// Connectivity overlap (ensures one connected solid)
overlap = 0.25;

// USB-A like block on right edge
usb_w = 14.0;   // along Y
usb_d = 16.0;   // protrusion along +X
usb_h = 7.0;    // height above PCB

// HDMI-like block on bottom edge
hdmi_w = 14.0;  // along X
hdmi_d = 11.0;  // protrusion along -Y
hdmi_h = 5.0;

// 40-pin header block on top edge
hdr_w = 52.0;   // along X
hdr_d = 6.0;    // along Y
hdr_h = 8.5;

// Main SoC block
soc_x = 14.0;
soc_y = 14.0;
soc_h = 2.0;

// Small power/IC block
pwr_x = 10.0;
pwr_y = 8.0;
pwr_h = 1.6;

// Rounded rectangle prism helper (centered)
module rounded_rect_prism(l, w, h, r) {
    r2 = min(r, min(l, w)/2 - 0.01);
    linear_extrude(height = h, center = true)
        offset(r = r2)
            square([l - 2*r2, w - 2*r2], center = true);
}

module pcb_with_holes() {
    difference() {
        // Standard 65x56 rectangle (no tabs/extensions)
        rounded_rect_prism(pcb_l, pcb_w, pcb_t, corner_r);

        // Through holes
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([
                sx * (pcb_l/2 - hole_edge_x),
                sy * (pcb_w/2 - hole_edge_y),
                0
            ])
            cylinder(h = pcb_t + 1.0, d = hole_d, center = true);
        }
    }
}

module sbc() {
    union() {
        pcb_with_holes();

        // USB-A connector (right edge, centered in Y) - connected via overlap
        translate([
            pcb_l/2 + usb_d/2 - overlap,
            0,
            pcb_t/2 + usb_h/2 - overlap
        ])
        cube([usb_d, usb_w, usb_h], center = true);

        // HDMI connector (bottom edge, slightly left of center) - connected via overlap
        translate([
            -pcb_l*0.15,
            -(pcb_w/2 + hdmi_d/2 - overlap),
            pcb_t/2 + hdmi_h/2 - overlap
        ])
        cube([hdmi_w, hdmi_d, hdmi_h], center = true);

        // 40-pin header (top edge) - connected via overlap
        translate([
            0,
            pcb_w/2 - hdr_d/2 + overlap,
            pcb_t/2 + hdr_h/2 - overlap
        ])
        cube([hdr_w, hdr_d, hdr_h], center = true);

        // SoC (on top surface, left-ish) - connected via overlap
        translate([
            -pcb_l*0.18,
            0,
            pcb_t/2 + soc_h/2 - overlap
        ])
        cube([soc_x, soc_y, soc_h], center = true);

        // Small power/IC block (top surface, near bottom-left) - connected via overlap
        translate([
            -pcb_l/2 + (hole_edge_x + pwr_x/2 + 6),
            -pcb_w/2 + (hole_edge_y + pwr_y/2 + 6),
            pcb_t/2 + pwr_h/2 - overlap
        ])
        cube([pwr_x, pwr_y, pwr_h], center = true);
    }
}

sbc();