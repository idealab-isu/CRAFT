$fn = 64;

// --- Parameters (mm) ---
pcb_length = 68.58;
pcb_width  = 53.34;
pcb_thickness = 1.6;

corner_radius = 3;

hole_diameter = 3.2;
hole_edge_offset_x = 5;
hole_edge_offset_y = 5;

overlap = 0.6;   // small overlap to guarantee single connected solid

// Typical dev-board features (approximate)
usb_w = 9.0;
usb_d = 7.5;
usb_h = 3.2;

mcu_l = 14;
mcu_w = 14;
mcu_h = 1.6;

reg_l = 8;
reg_w = 6;
reg_h = 1.2;

cap_r = 2.2;
cap_h = 2.8;

led_r = 1.0;
led_h = 0.8;

header_len = pcb_length - 2*(corner_radius + 2); // keep inside rounded corners
header_w = 2.54;
header_h = 6.0;

// --- Helpers ---
module rounded_rect_prism(l, w, h, r) {
    // 2D rounded rectangle extruded
    linear_extrude(height=h, center=true)
        offset(r=r)
            square([l - 2*r, w - 2*r], center=true);
}

module pcb_body_with_holes() {
    difference() {
        color([0.0, 0.4, 0.2])
            rounded_rect_prism(pcb_length, pcb_width, pcb_thickness, corner_radius);

        // Mounting holes
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*(pcb_length/2 - hole_edge_offset_x),
                       sy*(pcb_width/2  - hole_edge_offset_y),
                       0])
                cylinder(h=pcb_thickness + 2*overlap, r=hole_diameter/2, center=true);
        }
    }
}

// --- Components (all connected via overlap into PCB) ---
module usb_connector() {
    // Place on +Y edge, protruding outward, but overlapping into PCB
    // Inner face at y = pcb_width/2 - overlap
    translate([0,
               pcb_width/2 + usb_d/2 - overlap,
               pcb_thickness/2 + usb_h/2 - overlap])
        color("DimGray")
            cube([usb_w, usb_d, usb_h], center=true);
}

module pin_headers() {
    // Two long headers along left/right edges (X direction length)
    // Left header near -Y edge, right header near +Y edge (common dev-board layout)
    translate([0,
               -pcb_width/2 + header_w/2 - overlap,
               pcb_thickness/2 + header_h/2 - overlap])
        color("Black")
            cube([header_len, header_w, header_h], center=true);

    translate([0,
               pcb_width/2 - header_w/2 + overlap,
               pcb_thickness/2 + header_h/2 - overlap])
        color("Black")
            cube([header_len, header_w, header_h], center=true);
}

module mcu_chip() {
    // Center-ish MCU on top
    translate([0,
               0,
               pcb_thickness/2 + mcu_h/2 - overlap])
        color([0.1,0.1,0.1])
            cube([mcu_l, mcu_w, mcu_h], center=true);
}

module power_regulator() {
    // Small IC near USB side
    translate([-(pcb_length*0.22),
               pcb_width*0.22,
               pcb_thickness/2 + reg_h/2 - overlap])
        color([0.12,0.12,0.12])
            cube([reg_l, reg_w, reg_h], center=true);
}

module capacitors() {
    // A couple of caps near regulator/USB
    for (dx = [-1, 1]) {
        translate([-(pcb_length*0.22) + dx*6,
                   pcb_width*0.12,
                   pcb_thickness/2 + cap_h/2 - overlap])
            color([0.75,0.75,0.75])
                cylinder(h=cap_h, r=cap_r, center=true);
    }
}

module leds() {
    // Two small LEDs near one edge
    for (i = [0:1]) {
        translate([pcb_length*0.28 + i*4,
                   -pcb_width*0.18,
                   pcb_thickness/2 + led_h/2 - overlap])
            color([0.9,0.1,0.1])
                cylinder(h=led_h, r=led_r, center=true);
    }
}

module silkscreen() {
    // Thin silkscreen layer on top, overlapping slightly into PCB
    silkscreen_thickness = 0.08;
    silkscreen_margin = 2.0;

    translate([0, 0, pcb_thickness/2 + silkscreen_thickness/2 - overlap/2])
        color("White")
            rounded_rect_prism(pcb_length - 2*silkscreen_margin,
                               pcb_width  - 2*silkscreen_margin,
                               silkscreen_thickness,
                               max(0.5, corner_radius - silkscreen_margin/2));
}

// --- Complete model (single connected solid) ---
module complete_model() {
    union() {
        pcb_body_with_holes();

        // Top-side features
        usb_connector();
        pin_headers();
        mcu_chip();
        power_regulator();
        capacitors();
        leds();
        silkscreen();
    }
}

complete_model();