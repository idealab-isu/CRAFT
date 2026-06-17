// Stepper motor driver board (single connected solid)
// Target PCB: 20.0mm x 14.0mm x 1.6mm

$fn = 64;

// -------------------- Parameters --------------------
pcb_length    = 20.0;   // X
pcb_width     = 14.0;   // Y
pcb_thickness = 1.6;    // Z

corner_chamfer = 0.9;   // visual chamfer size (mm)

hole_diameter    = 2.2;
hole_edge_offset = 2.0;

attach_overlap = 0.25;  // overlap to guarantee connectivity (union robustness)

// Header (2x 1x8 typical)
header_pitch  = 2.54;
header_pins   = 8;
header_pin_d  = 0.9;
header_pin_h  = 6.0;    // longer so side views read as "pins"

header_body_w = 2.6;    // along Y
header_body_h = 2.2;    // above PCB
header_body_l = (header_pins - 1) * header_pitch + 2.0; // along X

// Recognizable driver-board features (A4988/DRV8825-like)
ic_l = 9.0;
ic_w = 7.0;
ic_h = 1.2;

heatsink_l = 9.5;
heatsink_w = 9.5;
heatsink_h = 4.0;       // keep within a compact overall height

pot_size = 4.8;
pot_h    = 2.2;

cap_d = 4.0;
cap_h = 5.0;

sense_l = 3.2;          // two small sense resistors
sense_w = 1.6;
sense_h = 0.9;

logic_l = 3.0;          // small logic IC
logic_w = 3.0;
logic_h = 1.0;

// -------------------- Helpers --------------------
module chamfered_pcb(l, w, t, c) {
    difference() {
        cube([l, w, t], center=true);

        // Corner chamfers (subtract rotated cubes)
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*(l/2 - c/2), sy*(w/2 - c/2), 0])
                rotate([0,0,45])
                    cube([c*sqrt(2), c*sqrt(2), t + 2*attach_overlap], center=true);
        }
    }
}

module mounting_holes(l, w, t, d, off) {
    for (sx = [-1, 1], sy = [-1, 1]) {
        translate([sx*(l/2 - off), sy*(w/2 - off), 0])
            cylinder(h=t + 2*attach_overlap, r=d/2, center=true);
    }
}

module pin_header_row(x_center, y_edge_sign) {
    // y_edge_sign: +1 for top edge (positive Y), -1 for bottom edge (negative Y)
    y_body = y_edge_sign*(pcb_width/2 - header_body_w/2);
    y_pin  = y_edge_sign*(pcb_width/2 - 1.0); // pins near edge, inside board

    // Plastic body overlaps slightly into PCB
    z_body = pcb_thickness/2 + header_body_h/2 - attach_overlap;

    // Pins start at PCB top and extend upward; overlap into PCB for connectivity
    z_pin  = pcb_thickness/2 + header_pin_h/2 - attach_overlap;

    union() {
        translate([x_center, y_body, z_body])
            cube([header_body_l, header_body_w, header_body_h], center=true);

        for (i = [0:header_pins-1]) {
            x = x_center - (header_pins-1)*header_pitch/2 + i*header_pitch;
            translate([x, y_pin, z_pin])
                cylinder(h=header_pin_h, r=header_pin_d/2, center=true);
        }
    }
}

module top_components() {
    // All components overlap into PCB by attach_overlap to ensure one connected solid
    union() {
        // Driver IC centered
        translate([0, 0, pcb_thickness/2 + ic_h/2 - attach_overlap])
            cube([ic_l, ic_w, ic_h], center=true);

        // Heatsink above IC (slightly offset in Y)
        translate([0, 0.6, pcb_thickness/2 + ic_h + heatsink_h/2 - attach_overlap])
            cube([heatsink_l, heatsink_w, heatsink_h], center=true);

        // Trimpot near +X +Y corner (computed from board size)
        translate([ pcb_length/2 - (pot_size/2 + 2.0),
                    pcb_width/2  - (pot_size/2 + 2.0),
                    pcb_thickness/2 + pot_h/2 - attach_overlap ])
            cube([pot_size, pot_size, pot_h], center=true);

        // Capacitor near -X side, centered in Y
        translate([ -pcb_length/2 + (cap_d/2 + 2.0),
                    0,
                    pcb_thickness/2 + cap_h/2 - attach_overlap ])
            cylinder(h=cap_h, r=cap_d/2, center=true);

        // Two sense resistors near -Y side (typical placement)
        for (sx = [-1, 1]) {
            translate([ sx*(sense_l/2 + 1.8),
                        -pcb_width/2 + (sense_w/2 + 3.0),
                        pcb_thickness/2 + sense_h/2 - attach_overlap ])
                cube([sense_l, sense_w, sense_h], center=true);
        }

        // Small logic IC near +Y, left of center
        translate([ -pcb_length/2 + (logic_l/2 + 6.0),
                    pcb_width/2 - (logic_w/2 + 3.2),
                    pcb_thickness/2 + logic_h/2 - attach_overlap ])
            cube([logic_l, logic_w, logic_h], center=true);
    }
}

module bottom_features() {
    // Add a small underside solder-mask "bump" / pad area so bottom view isn't blank.
    // Overlaps into PCB to remain one solid.
    pad_l = pcb_length - 4.0;
    pad_w = pcb_width  - 6.0;
    pad_h = 0.4;

    translate([0, 0, -pcb_thickness/2 - pad_h/2 + attach_overlap])
        cube([pad_l, pad_w, pad_h], center=true);
}

module board_model() {
    union() {
        // PCB with holes and chamfers
        difference() {
            chamfered_pcb(pcb_length, pcb_width, pcb_thickness, corner_chamfer);
            mounting_holes(pcb_length, pcb_width, pcb_thickness, hole_diameter, hole_edge_offset);
        }

        // Two header rows
        pin_header_row(0, +1);
        pin_header_row(0, -1);

        // Top-side components
        top_components();

        // Bottom-side pad area (still one connected solid)
        bottom_features();
    }
}

board_model();