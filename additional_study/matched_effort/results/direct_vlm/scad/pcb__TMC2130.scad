$fn = 64;

// Stepper motor driver board (approx. Pololu-style carrier)
// Overall PCB size must be 20.0 x 14.0 x 1.6 mm
board_x = 20.0;
board_y = 14.0;
board_z = 1.6;

eps = 0.2; // small overlap to guarantee connectivity

// PCB corner radius (visual)
pcb_r = 1.0;

// Pin header geometry (two rows)
pin_rows = 2;
pins_per_row = 8;
pin_pitch = 2.54;

pin_d = 0.7;
pin_h = 6.0;          // protruding below PCB
pin_embed = 0.6;      // embedded into PCB for solid union

// Header plastic (sits on top of PCB)
hdr_x = (pins_per_row - 1) * pin_pitch + 2.0;
hdr_y = 2.6;
hdr_z = 2.2;

// Placement of header rows from PCB center
row_offset_y = (board_y/2) - 2.0; // near long edges, but inside outline

// Main IC package on top
ic_x = 9.0;
ic_y = 9.0;
ic_z = 1.2;

// Small trimpot on top
pot_x = 4.2;
pot_y = 4.2;
pot_z = 2.2;

// Small capacitor on top
cap_r = 1.2;
cap_h = 2.0;

// Helper: rounded rectangle prism
module rounded_rect_prism(x, y, z, r) {
    r2 = min(r, min(x, y)/2);
    linear_extrude(height=z)
        offset(r=r2)
            square([x - 2*r2, y - 2*r2], center=true);
}

module pin_at(x, y) {
    // Centered cylinder, embedded slightly into PCB to ensure union
    translate([x, y, -pin_h/2 + pin_embed/2])
        cylinder(h=pin_h + pin_embed, d=pin_d, center=true);
}

union() {
    // PCB (centered for easier feature placement)
    color([0.05, 0.45, 0.12])
        translate([0, 0, board_z/2])
            rounded_rect_prism(board_x, board_y, board_z, pcb_r);

    // Two header plastic bodies on top (connected with slight overlap)
    for (side = [-1, 1]) {
        translate([0, side*row_offset_y, board_z + hdr_z/2 - eps])
            color([0.1, 0.1, 0.1])
                cube([hdr_x, hdr_y, hdr_z], center=true);
    }

    // Pins (two rows of 8), protruding below PCB and embedded into it
    for (side = [-1, 1]) {
        for (i = [0 : pins_per_row-1]) {
            x = -((pins_per_row-1) * pin_pitch)/2 + i*pin_pitch;
            y = side*row_offset_y;
            color([0.8, 0.7, 0.2]) pin_at(x, y);
        }
    }

    // Main IC on top (centered)
    translate([0, 0, board_z + ic_z/2 - eps])
        color([0.15, 0.15, 0.15])
            cube([ic_x, ic_y, ic_z], center=true);

    // Trimpot near one end (top side)
    translate([board_x/2 - pot_x/2 - 2.0, 0, board_z + pot_z/2 - eps])
        color([0.05, 0.2, 0.6])
            cube([pot_x, pot_y, pot_z], center=true);

    // Capacitor near opposite end (top side)
    translate([-board_x/2 + 3.0, 0, board_z + cap_h/2 - eps])
        color([0.2, 0.2, 0.2])
            cylinder(h=cap_h, r=cap_r, center=true);
}