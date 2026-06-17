// Rotary encoder breakout board (single connected solid)
// Target PCB: 26.3mm x 19.5mm x 1.6mm

$fn = 64;

// -------------------- Parameters --------------------
pcb_L = 26.3;
pcb_W = 19.5;
pcb_T = 1.6;

corner_R = 1.0;

mount_hole_d = 2.2;
mount_hole_edge_offset = 2.5;

header_pins = 5;
header_pitch = 2.54;
header_hole_d = 1.0;
header_row_offset_from_edge = 2.0;

overlap = 0.6;          // overlap to guarantee connectivity
eps = 0.01;

// Encoder (visual model)
encoder_body_D = 16.0;
encoder_body_H = 11.0;

encoder_shaft_D = 6.0;
encoder_shaft_H = 12.0;

encoder_boss_D = 10.0;
encoder_boss_H = 2.0;

// Place encoder centered on PCB
encoder_center_offset_x = 0;
encoder_center_offset_y = 0;

// Pin visuals (through-hole header)
pin_D = 0.7;
pin_above = 3.0;
pin_below = 3.0;

// -------------------- Helpers --------------------
module rounded_rect_prism(L, W, H, R) {
    // Rounded rectangle prism using hull of corner cylinders
    hull() {
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*(L/2 - R), sy*(W/2 - R), 0])
                cylinder(r=R, h=H, center=true);
        }
    }
}

module pcb_solid() {
    difference() {
        rounded_rect_prism(pcb_L, pcb_W, pcb_T, corner_R);

        // Mounting holes (4 corners)
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*(pcb_L/2 - mount_hole_edge_offset),
                       sy*(pcb_W/2 - mount_hole_edge_offset),
                       0])
                cylinder(d=mount_hole_d, h=pcb_T + 2*overlap, center=true);
        }

        // Header holes along one edge (bottom edge in Y-)
        for (i = [0:header_pins-1]) {
            x = -((header_pins-1)*header_pitch)/2 + i*header_pitch;
            y = -(pcb_W/2 - header_row_offset_from_edge);
            translate([x, y, 0])
                cylinder(d=header_hole_d, h=pcb_T + 2*overlap, center=true);
        }
    }
}

module encoder_body() {
    // Encoder body sits on top of PCB and is connected with slight overlap
    z0 = pcb_T/2 + encoder_body_H/2 - overlap;

    translate([encoder_center_offset_x, encoder_center_offset_y, z0])
        cylinder(d=encoder_body_D, h=encoder_body_H, center=true);

    // Small boss on top of body
    z_boss = pcb_T/2 + encoder_body_H + encoder_boss_H/2 - overlap;
    translate([encoder_center_offset_x, encoder_center_offset_y, z_boss])
        cylinder(d=encoder_boss_D, h=encoder_boss_H, center=true);

    // Shaft on top of boss
    z_shaft = pcb_T/2 + encoder_body_H + encoder_boss_H + encoder_shaft_H/2 - overlap;
    translate([encoder_center_offset_x, encoder_center_offset_y, z_shaft])
        cylinder(d=encoder_shaft_D, h=encoder_shaft_H, center=true);
}

module header_pins_solid() {
    // Visual pins that pass through the PCB holes and connect to PCB via overlap
    for (i = [0:header_pins-1]) {
        x = -((header_pins-1)*header_pitch)/2 + i*header_pitch;
        y = -(pcb_W/2 - header_row_offset_from_edge);

        // Pin spans below PCB to above PCB; ensure overlap into PCB
        pin_h = pin_below + pcb_T + pin_above;
        z_pin = -pin_below/2 + pin_above/2; // centers so bottom extends below
        translate([x, y, z_pin])
            cylinder(d=pin_D, h=pin_h + 2*overlap, center=true);
    }
}

module keep_connected_bridge() {
    // A tiny hidden bridge to guarantee single connected solid even if tolerances change.
    // Connects encoder body to PCB with a small rib (overlaps both).
    rib_w = 2.0;
    rib_l = 6.0;
    rib_h = pcb_T/2 + 1.0;

    // From PCB top into encoder body side
    z = pcb_T/2 + rib_h/2 - overlap;
    translate([encoder_center_offset_x, encoder_center_offset_y - (encoder_body_D/2 - rib_l/2), z])
        cube([rib_w, rib_l, rib_h], center=true);
}

// -------------------- Final Model (ONE connected solid) --------------------
union() {
    pcb_solid();
    encoder_body();
    header_pins_solid();
    keep_connected_bridge();
}