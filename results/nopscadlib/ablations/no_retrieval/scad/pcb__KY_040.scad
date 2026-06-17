$fn = 64;

// --- Target board dimensions (verifiable) ---
pcb_length = 26.3;
pcb_width  = 19.5;
pcb_thickness = 1.6;

// --- Board details ---
corner_radius = 1.0;
mount_hole_diameter = 2.2;
mount_hole_edge_offset = 2.5;

// --- Header footprint (typical breakout) ---
header_pin_count = 5;
header_pitch = 2.54;
pad_hole_diameter = 1.0;
header_edge_offset = 2.0;

// --- Encoder body + shaft (recognizable) ---
encoder_body_length = 14.0;
encoder_body_width  = 14.0;
encoder_body_height = 6.0;
encoder_edge_offset = 3.5; // from top edge inward

shaft_d = 6.0;
shaft_h = 12.0;

// --- Single-solid overlap ---
overlap = 0.6;

// ---------- Helpers ----------
module rounded_rect_prism(l, w, h, r) {
    // Minkowski gives true rounded corners and a single solid
    minkowski() {
        cube([l - 2*r, w - 2*r, h], center=true);
        cylinder(r=r, h=0.01, center=true);
    }
}

module pcb_solid() {
    // PCB with holes removed (still a single solid)
    difference() {
        rounded_rect_prism(pcb_length, pcb_width, pcb_thickness, corner_radius);

        // 4 mounting holes
        for (x = [-1, 1], y = [-1, 1]) {
            translate([x*(pcb_length/2 - mount_hole_edge_offset),
                       y*(pcb_width/2  - mount_hole_edge_offset),
                       0])
                cylinder(d=mount_hole_diameter, h=pcb_thickness + 2*overlap, center=true);
        }

        // header drills (through holes)
        for (i = [0:header_pin_count-1]) {
            translate([i*header_pitch - ((header_pin_count-1)*header_pitch)/2,
                       -pcb_width/2 + header_edge_offset,
                       0])
                cylinder(d=pad_hole_diameter, h=pcb_thickness + 2*overlap, center=true);
        }
    }
}

module encoder_body_and_shaft() {
    // Place encoder body near top edge, on top of PCB
    enc_y = pcb_width/2 - encoder_edge_offset - encoder_body_width/2;
    enc_z = pcb_thickness/2 + encoder_body_height/2 - overlap;

    // Body
    translate([0, enc_y, enc_z])
        cube([encoder_body_length, encoder_body_width, encoder_body_height], center=true);

    // Shaft centered on body, protruding upward, with slight overlap into body
    shaft_z = (pcb_thickness/2 + encoder_body_height) + shaft_h/2 - overlap;
    translate([0, enc_y, shaft_z])
        cylinder(d=shaft_d, h=shaft_h, center=true);
}

module header_block() {
    // A simple connected representation of a 1x5 header on the bottom edge (top side of PCB)
    header_len = (header_pin_count-1)*header_pitch + 2.0;
    header_w   = 5.0;
    header_h   = 4.0;

    header_y = -pcb_width/2 + header_edge_offset + header_w/2 - overlap;
    header_z = pcb_thickness/2 + header_h/2 - overlap;

    translate([0, header_y, header_z])
        cube([header_len, header_w, header_h], center=true);
}

// ---------- Complete connected solid ----------
union() {
    pcb_solid();
    encoder_body_and_shaft();
    header_block();
}