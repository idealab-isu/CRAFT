$fn = 64;

// ---------------- Parameters (mm) ----------------
pcb_L = 110.0;
pcb_W = 85.0;
pcb_T = 1.6;

corner_R = 4.0;

// Mounting holes (typical mainboard pattern)
hole_d = 3.2;
hole_edge_offset = 6.0;

// Small overlap to guarantee one connected solid
overlap = 0.6;

// Silhouette tabs (match provided views: top/bottom centered, left/right centered)
tab_top_W    = 14.0;
tab_top_L    = 10.0;   // protrusion in +Y
tab_right_L  = 12.0;   // protrusion in +X
tab_right_W  = 18.0;   // width in Y
tab_bottom_W = 16.0;
tab_bottom_L = 12.0;   // protrusion in -Y
tab_left_L   = 14.0;   // protrusion in -X
tab_left_W   = 18.0;

// Component envelopes (simple but recognizable)
usb_L = 14.0; usb_W = 12.0; usb_H = 7.0;     // USB on right edge
term_L = 18.0; term_W = 14.0; term_H = 12.0; // terminal block on top edge
pin_L = 50.0; pin_W = 6.0;  pin_H = 8.0;     // pin header near bottom
hs_L = 20.0;  hs_W = 20.0;  hs_H = 12.0;     // heatsink block

// Extra "board features" to look like a mainboard (low-profile parts)
mcu_L = 18.0; mcu_W = 18.0; mcu_H = 2.0;     // main IC
cap_d = 6.0;  cap_H = 10.0;                  // electrolytic caps
driver_L = 15.0; driver_W = 15.0; driver_H = 3.0; // stepper driver modules

// ---------------- Helpers ----------------
module rounded_rect_2d(L, W, R) {
    hull() {
        translate([ L/2 - R,  W/2 - R]) circle(r=R);
        translate([ L/2 - R, -W/2 + R]) circle(r=R);
        translate([-L/2 + R,  W/2 - R]) circle(r=R);
        translate([-L/2 + R, -W/2 + R]) circle(r=R);
    }
}

module pcb_outline_2d() {
    union() {
        rounded_rect_2d(pcb_L, pcb_W, corner_R);

        // Tabs unioned into outline (no arbitrary offsets)
        translate([0, pcb_W/2 + tab_top_L/2])
            square([tab_top_W, tab_top_L], center=true);

        translate([pcb_L/2 + tab_right_L/2, 0])
            square([tab_right_L, tab_right_W], center=true);

        translate([0, -(pcb_W/2 + tab_bottom_L/2)])
            square([tab_bottom_W, tab_bottom_L], center=true);

        translate([-(pcb_L/2 + tab_left_L/2), 0])
            square([tab_left_L, tab_left_W], center=true);
    }
}

module pcb_solid() {
    linear_extrude(height=pcb_T, center=true)
        pcb_outline_2d();
}

module mounting_holes() {
    // Through holes (taller than PCB for clean subtraction)
    h = pcb_T * 8;
    for (sx = [-1, 1], sy = [-1, 1]) {
        translate([sx*(pcb_L/2 - hole_edge_offset),
                   sy*(pcb_W/2 - hole_edge_offset),
                   0])
            cylinder(h=h, r=hole_d/2, center=true);
    }
}

module pcb_with_holes() {
    difference() {
        pcb_solid();
        mounting_holes();
    }
}

// ---------------- Components (all connected via computed placement) ----------------
module usb_conn() {
    // Right edge (+X), centered in Y, sits on top of PCB with overlap
    translate([
        pcb_L/2 + usb_L/2 - overlap,
        0,
        pcb_T/2 + usb_H/2 - overlap
    ])
        cube([usb_L, usb_W, usb_H], center=true);
}

module term_block() {
    // Top edge (+Y), centered in X
    translate([
        0,
        pcb_W/2 + term_L/2 - overlap,
        pcb_T/2 + term_H/2 - overlap
    ])
        cube([term_W, term_L, term_H], center=true);
}

module pin_header() {
    // Near bottom (-Y), inset from edge (still on top of PCB)
    inset = 8.0;
    translate([
        0,
        -(pcb_W/2 - pin_W/2 - inset),
        pcb_T/2 + pin_H/2 - overlap
    ])
        cube([pin_L, pin_W, pin_H], center=true);
}

module heatsink() {
    // Left half of board (-X)
    x_inset = 18.0;
    translate([
        -(pcb_L/2 - hs_L/2 - x_inset),
        0,
        pcb_T/2 + hs_H/2 - overlap
    ])
        cube([hs_L, hs_W, hs_H], center=true);
}

module mcu_ic() {
    // Central-ish low-profile IC
    translate([
        0,
        6.0,
        pcb_T/2 + mcu_H/2 - overlap
    ])
        cube([mcu_L, mcu_W, mcu_H], center=true);
}

module electrolytic_caps() {
    // Two caps near terminal block area
    x_off = term_W/2 + cap_d/2 + 4.0;
    y_pos = pcb_W/2 - cap_d/2 - 10.0;
    for (sx = [-1, 1]) {
        translate([
            sx * x_off,
            y_pos,
            pcb_T/2 + cap_H/2 - overlap
        ])
            cylinder(h=cap_H, r=cap_d/2, center=true);
    }
}

module stepper_drivers() {
    // Three small modules in a row (recognizable mainboard feature)
    n = 3;
    spacing = driver_L + 4.0;
    y_pos = -6.0;
    x0 = -spacing*(n-1)/2;
    for (i = [0:n-1]) {
        translate([
            x0 + i*spacing,
            y_pos,
            pcb_T/2 + driver_H/2 - overlap
        ])
            cube([driver_L, driver_W, driver_H], center=true);
    }
}

module underside_feature() {
    // A small underside block to make bottom view less like a plain plate
    // (still connected: overlaps into PCB from below)
    u_L = 26.0; u_W = 18.0; u_H = 4.0;
    translate([
        0,
        -10.0,
        -(pcb_T/2 + u_H/2 - overlap)
    ])
        cube([u_L, u_W, u_H], center=true);
}

// ---------------- Complete model ----------------
module complete_mainboard_model() {
    union() {
        pcb_with_holes();

        // Top-side components
        usb_conn();
        term_block();
        pin_header();
        heatsink();
        mcu_ic();
        electrolytic_caps();
        stepper_drivers();

        // Bottom-side feature
        underside_feature();
    }
}

// Render (single connected solid)
color([0.0, 0.4, 0.2]) complete_mainboard_model();