$fn = 64;

// =====================
// Stepper driver module (generic Pololu-style)
// Requested PCB: 20.0 x 14.0 x 1.6 mm
// One connected solid (all parts overlap slightly into PCB)
// =====================

// Board parameters (requested)
pcb_length    = 20.0;
pcb_width     = 14.0;
pcb_thickness = 1.6;

// Board details
corner_r = 0.8;

// Typical mounting holes (many driver boards have none; keep subtle + optional)
use_mounting_holes = false;
hole_d = 2.0;
hole_offset_x = 2.0;
hole_offset_y = 2.0;

// Connectivity overlap (ensures union is one solid)
overlap = 0.25;

// Header parameters (2x 1x8 along long edges)
header_rows = 1;                 // each side is a single row
header_pins_per_row = 8;
pin_pitch = 2.54;
pin_d = 0.9;
pin_h = 3.2;                     // pins above PCB
pin_tail_h = 2.2;                // pins below PCB (solder tail)
header_body_h = 2.0;
header_body_w = 2.6;
header_body_l = (header_pins_per_row - 1) * pin_pitch + 2.0;

// Component approximations (simple but recognizable)
chip_l = 6.2;
chip_w = 6.2;
chip_h = 1.2;

heatsink_l = 8.0;
heatsink_w = 8.0;
heatsink_h = 2.0;

trimpot_l = 4.8;
trimpot_w = 4.8;
trimpot_h = 2.4;

cap_d = 3.2;
cap_h = 2.4;

conn_l = 6.0;   // small 2-pin/3-pin style connector block
conn_w = 4.0;
conn_h = 3.0;

// Helpers
module rounded_rect_2d(l, w, r) {
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(l/2 - r), sy*(w/2 - r)]) circle(r=r);
    }
}

module pcb_solid() {
    linear_extrude(height=pcb_thickness)
        rounded_rect_2d(pcb_length, pcb_width, corner_r);
}

module mounting_holes() {
    for (sx = [-1, 1], sy = [-1, 1]) {
        translate([sx*(pcb_length/2 - hole_offset_x),
                   sy*(pcb_width/2  - hole_offset_y),
                   pcb_thickness/2])
            cylinder(h=pcb_thickness + 0.6, d=hole_d, center=true);
    }
}

module header_1xN_with_pins() {
    union() {
        // plastic body sits on top of PCB and overlaps slightly into it
        translate([0, 0, pcb_thickness + header_body_h/2 - overlap])
            cube([header_body_l, header_body_w, header_body_h], center=true);

        // pins: extend above and below PCB; overlap into PCB for connectivity
        for (i = [0:header_pins_per_row-1]) {
            xoff = -((header_pins_per_row-1)*pin_pitch)/2 + i*pin_pitch;

            // upper pin
            translate([xoff, 0, pcb_thickness + pin_h/2 - overlap])
                cylinder(h=pin_h, d=pin_d, center=true);

            // lower tail
            translate([xoff, 0, -pin_tail_h/2 + overlap])
                cylinder(h=pin_tail_h, d=pin_d, center=true);
        }
    }
}

module components_top() {
    union() {
        // Main driver IC
        translate([0, 0, pcb_thickness + chip_h/2 - overlap])
            cube([chip_l, chip_w, chip_h], center=true);

        // Heatsink block on top of IC (common on some modules)
        translate([0, 0, pcb_thickness + chip_h + heatsink_h/2 - overlap])
            cube([heatsink_l, heatsink_w, heatsink_h], center=true);

        // Trimpot near one end (toward +X)
        translate([pcb_length*0.28, pcb_width*0.18, pcb_thickness + trimpot_h/2 - overlap])
            cube([trimpot_l, trimpot_w, trimpot_h], center=true);

        // Electrolytic capacitor near opposite side
        translate([-pcb_length*0.28, -pcb_width*0.18, pcb_thickness + cap_h/2 - overlap])
            cylinder(h=cap_h, d=cap_d, center=true);

        // Small connector block near -X edge (visual feature)
        // Keep it within board outline and connected via overlap
        conn_x = -pcb_length/2 + conn_l/2 + 1.0;
        conn_y = 0;
        translate([conn_x, conn_y, pcb_thickness + conn_h/2 - overlap])
            cube([conn_l, conn_w, conn_h], center=true);
    }
}

module stepper_driver_board() {
    union() {
        // PCB (with optional holes)
        if (use_mounting_holes) {
            difference() {
                pcb_solid();
                mounting_holes();
            }
        } else {
            pcb_solid();
        }

        // Two long pin headers along the long edges
        header_inset = 1.0;
        header_y = pcb_width/2 - header_inset - header_body_w/2;

        translate([0,  header_y, 0]) header_1xN_with_pins();
        translate([0, -header_y, 0]) header_1xN_with_pins();

        // Top-side components
        components_top();
    }
}

// Build
stepper_driver_board();