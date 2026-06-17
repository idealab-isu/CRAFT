$fn = 64;

// Control board overall size (verified by parameters)
board_x  = 33.8;
board_y  = 37.5;
board_th = 1.6;

// Small overlap to guarantee watertight unions
eps = 0.2;

// ---------- Feature parameters (generic control-board look) ----------
corner_r = 1.2;

// Mounting holes (typical 3mm clearance) and offsets from edges
hole_d = 3.2;
hole_edge_x = 3.0;
hole_edge_y = 3.0;

// Components (kept within board outline and connected)
soldermask_bump = 0.25;   // subtle raised "silkscreen/soldermask" areas
ic_h   = 1.2;
ic_x   = 12.0;
ic_y   = 12.0;

usb_w  = 8.0;
usb_d  = 6.0;
usb_h  = 3.2;

term_w = 10.0;
term_d = 7.0;
term_h = 6.0;

pin_w  = 14.0;
pin_d  = 5.0;
pin_h  = 3.0;

cap_r  = 3.0;
cap_h  = 6.0;

// ---------- Helpers ----------
module rounded_rect_prism(x, y, z, r) {
    // Rounded rectangle via hull of corner cylinders
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(x/2 - r), sy*(y/2 - r), 0])
                cylinder(r=r, h=z, center=true);
    }
}

module mount_holes() {
    for (sx = [-1, 1], sy = [-1, 1])
        translate([sx*(board_x/2 - hole_edge_x), sy*(board_y/2 - hole_edge_y), 0])
            cylinder(d=hole_d, h=board_th + 2, center=true);
}

// ---------- Model (ONE connected solid) ----------
union() {
    // PCB with mounting holes
    color([0.05, 0.45, 0.12])
    difference() {
        translate([0, 0, board_th/2])
            rounded_rect_prism(board_x, board_y, board_th, corner_r);
        translate([0, 0, board_th/2])
            mount_holes();
    }

    // Subtle raised regions on top (kept connected by overlapping into PCB)
    color([0.08, 0.55, 0.18])
    translate([0, 0, board_th + soldermask_bump/2 - eps])
        rounded_rect_prism(board_x*0.78, board_y*0.78, soldermask_bump, 0.8);

    // Main IC (center)
    color([0.15, 0.15, 0.15])
    translate([0, 0, board_th + ic_h/2 - eps])
        cube([ic_x, ic_y, ic_h], center=true);

    // USB-like connector on +Y edge (centered)
    color([0.75, 0.75, 0.75])
    translate([0,
               board_y/2 - usb_d/2 + eps,
               board_th + usb_h/2 - eps])
        cube([usb_w, usb_d, usb_h], center=true);

    // Screw terminal on -Y edge (offset to +X)
    color([0.1, 0.35, 0.75])
    translate([board_x*0.22,
               -board_y/2 + term_d/2 - eps,
               board_th + term_h/2 - eps])
        cube([term_w, term_d, term_h], center=true);

    // Pin header on -X edge (centered in Y)
    color([0.2, 0.2, 0.2])
    translate([-board_x/2 + pin_d/2 - eps,
               0,
               board_th + pin_h/2 - eps])
        cube([pin_d, pin_w, pin_h], center=true);

    // Electrolytic capacitor (near +X, -Y quadrant)
    color([0.05, 0.05, 0.05])
    translate([board_x/2 - (cap_r + 4.0),
               -board_y/2 + (cap_r + 6.0),
               board_th + cap_h/2 - eps])
        cylinder(r=cap_r, h=cap_h, center=true);

    // Small "chips" cluster (top-left area)
    color([0.12, 0.12, 0.12])
    for (i = [0:2]) {
        chip_x = 5.0;
        chip_y = 3.2;
        chip_h = 1.0;
        gap = 1.2;
        translate([-board_x*0.22,
                   board_y*0.18 + i*(chip_y + gap) - (chip_y + gap),
                   board_th + chip_h/2 - eps])
            cube([chip_x, chip_y, chip_h], center=true);
    }
}