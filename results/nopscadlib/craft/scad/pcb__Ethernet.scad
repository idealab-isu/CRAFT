$fn = 64;

// Target PCB overall envelope (mm)
pcb_x = 33.8;   // X overall
pcb_y = 37.5;   // Y overall
pcb_z = 1.6;    // thickness

// Outline styling
corner_r = 2.0;

// Mounting holes
hole_d = 3.2;
hole_edge_margin = 3.5;

// Connectivity / robustness
eps = 0.15;     // overlap to guarantee one connected solid

// --- Outline tabs (kept within overall pcb_x/pcb_y) ---
// Central rounded rectangle size (tabs extend to reach overall size)
core_x = 27.0;
core_y = 27.0;

// Tabs on +Y and -Y (top/bottom)
tab_y_w = 12.0;
tab_y_len = (pcb_y - core_y)/2;   // each tab length in Y

// Tabs on +X and -X (right/left)
tab_x_h = 10.0;
tab_x_len = (pcb_x - core_x)/2;   // each tab length in X

// --- Simple component placeholders (all connected to PCB) ---
usb_w = 12.0;  usb_d = 8.0;  usb_h = 5.5;
term_w = 14.0; term_d = 9.0; term_h = 7.0;
header_w = 18.0; header_d = 6.0; header_h = 4.0;

chip_w = 12.0; chip_d = 12.0; chip_h = 2.0;
reg_w  = 8.0;  reg_d  = 10.0; reg_h  = 3.0;

// ---------- Helpers ----------
module rounded_rect_2d(w, l, r) {
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(w/2 - r), sy*(l/2 - r)]) circle(r=r);
    }
}

module pcb_outline_2d() {
    union() {
        // Core
        rounded_rect_2d(core_x, core_y, corner_r);

        // +Y tab (top)
        translate([0, core_y/2 + tab_y_len/2])
            square([tab_y_w, tab_y_len], center=true);

        // -Y tab (bottom)
        translate([0, -(core_y/2 + tab_y_len/2)])
            square([tab_y_w, tab_y_len], center=true);

        // +X tab (right)
        translate([core_x/2 + tab_x_len/2, 0])
            square([tab_x_len, tab_x_h], center=true);

        // -X tab (left)
        translate([-(core_x/2 + tab_x_len/2), 0])
            square([tab_x_len, tab_x_h], center=true);
    }
}

module pcb_solid() {
    difference() {
        linear_extrude(height=pcb_z, center=true)
            pcb_outline_2d();

        // Mounting holes (through)
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(core_x/2 - hole_edge_margin),
                       sy*(core_y/2 - hole_edge_margin),
                       0])
                cylinder(h=pcb_z + 2, r=hole_d/2, center=true);
    }
}

module top_feature(size_xyz, pos_xy) {
    translate([pos_xy[0], pos_xy[1], pcb_z/2 + size_xyz[2]/2 - eps])
        cube(size_xyz, center=true);
}

module side_feature_y(size_xyz, side, x_off=0) {
    translate([x_off,
               side*(pcb_y/2 + size_xyz[1]/2 - eps),
               pcb_z/2 + size_xyz[2]/2 - eps])
        cube(size_xyz, center=true);
}

module side_feature_x(size_xyz, side, y_off=0) {
    translate([side*(pcb_x/2 + size_xyz[0]/2 - eps),
               y_off,
               pcb_z/2 + size_xyz[2]/2 - eps])
        cube(size_xyz, center=true);
}

// ---------- Complete connected model ----------
union() {
    // PCB base with correct overall 33.8 x 37.5 x 1.6
    pcb_solid();

    // Edge connectors (connected, not floating)
    // USB-like connector on +Y edge, centered
    side_feature_y([usb_w, usb_d, usb_h], +1, 0);

    // Terminal block on -Y edge, slightly offset
    side_feature_y([term_w, term_d, term_h], -1, -pcb_x*0.12);

    // Side header on +X edge, slightly offset in Y
    side_feature_x([header_d, header_w, header_h], +1, pcb_y*0.10);

    // Additional small connector on -X edge to add realism
    side_feature_x([5.0, 10.0, 3.5], -1, -pcb_y*0.12);

    // Components on top surface (simple outlines)
    top_feature([chip_w, chip_d, chip_h], [ -pcb_x*0.10,  pcb_y*0.05 ]);
    top_feature([reg_w,  reg_d,  reg_h ], [  pcb_x*0.20, -pcb_y*0.18 ]);
    top_feature([10, 6, 2.2],              [ -pcb_x*0.25, -pcb_y*0.20 ]);

    // A couple of small passives for board detail
    top_feature([4.0, 2.0, 1.2], [ pcb_x*0.05,  pcb_y*0.18 ]);
    top_feature([4.0, 2.0, 1.2], [ pcb_x*0.12,  pcb_y*0.18 ]);
    top_feature([3.2, 3.2, 1.4], [ pcb_x*0.22,  pcb_y*0.02 ]);
}