$fn = 96;

// --- Target board size (must match) ---
pcb_length    = 26.3;
pcb_width     = 19.5;
pcb_thickness = 1.6;

// --- Board details ---
corner_radius = 2.0;

// Mounting holes (4x)
mount_hole_d  = 3.0;
mount_edge_x  = 3.0;   // from left/right edge to hole center
mount_edge_y  = 3.0;   // from top/bottom edge to hole center

// --- Typical breakout features (kept simple but recognizable) ---

// 1x5 header footprint (common for encoder breakouts: GND, VCC, SW, DT, CLK)
pin_pitch   = 2.54;
pin_count   = 5;
pin_hole_d  = 1.1;

// Copper pad (slightly raised) + annular ring look
pad_d       = 2.2;
pad_h       = 0.20;

// Header placement: along one long edge, centered in Y
header_edge_clear = 2.2; // from left edge to first pin center
header_y          = -pcb_width/2 + 3.0; // near bottom edge (formula-based)

// Encoder body (more realistic: can + boss + shaft, all ABOVE PCB)
encoder_body_d = 16.0;
encoder_body_h = 6.0;

encoder_boss_d = 9.0;
encoder_boss_h = 2.0;

encoder_shaft_d = 6.0;
encoder_shaft_h = 10.0;

// Encoder placement: centered on board
encoder_center = [0, 0];

// Small overlap to guarantee one connected solid
overlap = 0.25;

// --- Helpers ---
module rounded_rect_2d(L, W, R) {
    minkowski() {
        square([L - 2*R, W - 2*R], center=true);
        circle(r=R);
    }
}

module pcb_solid() {
    linear_extrude(height=pcb_thickness, center=true)
        rounded_rect_2d(pcb_length, pcb_width, corner_radius);
}

module mounting_holes_cut() {
    for (sx = [-1, 1])
        for (sy = [-1, 1]) {
            x = sx * (pcb_length/2 - mount_edge_x);
            y = sy * (pcb_width/2  - mount_edge_y);
            translate([x, y, 0])
                cylinder(h=pcb_thickness + 2, d=mount_hole_d, center=true);
        }
}

module header_holes_cut() {
    x0 = -pcb_length/2 + header_edge_clear;
    for (i = [0:pin_count-1]) {
        translate([x0 + i*pin_pitch, header_y, 0])
            cylinder(h=pcb_thickness + 2, d=pin_hole_d, center=true);
    }
}

module header_pads_top() {
    // Raised pads on top side, overlapping slightly into PCB to ensure connectivity
    x0 = -pcb_length/2 + header_edge_clear;
    z  = pcb_thickness/2 - overlap/2 + pad_h/2;
    for (i = [0:pin_count-1]) {
        translate([x0 + i*pin_pitch, header_y, z])
            cylinder(h=pad_h + overlap, d=pad_d, center=true);
    }
}

module header_pads_bottom() {
    // Bottom pads too (common on through-hole boards); also helps "PCB-like" look
    x0 = -pcb_length/2 + header_edge_clear;
    z  = -pcb_thickness/2 + overlap/2 - pad_h/2;
    for (i = [0:pin_count-1]) {
        translate([x0 + i*pin_pitch, header_y, z])
            cylinder(h=pad_h + overlap, d=pad_d, center=true);
    }
}

module encoder_body_top() {
    // All parts are ABOVE PCB (no large protrusion below board)
    z_top = pcb_thickness/2;

    // Main can
    translate([encoder_center[0], encoder_center[1], z_top + encoder_body_h/2 - overlap])
        cylinder(h=encoder_body_h + overlap, d=encoder_body_d, center=true);

    // Boss
    translate([encoder_center[0], encoder_center[1], z_top + encoder_body_h + encoder_boss_h/2 - overlap])
        cylinder(h=encoder_boss_h + overlap, d=encoder_boss_d, center=true);

    // Shaft
    translate([encoder_center[0], encoder_center[1], z_top + encoder_body_h + encoder_boss_h + encoder_shaft_h/2 - overlap])
        cylinder(h=encoder_shaft_h + overlap, d=encoder_shaft_d, center=true);
}

module encoder_footprint_pins_bottom() {
    // Simple through-hole pin stubs on the bottom side (typical encoder has 5 pins)
    // Kept short and overlapping into PCB so the whole model is one connected solid.
    pin_d = 1.0;
    pin_h = 2.2;

    // Approx positions: 3 signal pins + 2 mechanical tabs
    pts = [
        [-2.54, -5.0],
        [ 0.00, -5.0],
        [ 2.54, -5.0],
        [-5.5,  0.0],
        [ 5.5,  0.0]
    ];

    z = -pcb_thickness/2 - pin_h/2 + overlap; // mostly below, slightly into PCB
    for (p = pts) {
        translate([encoder_center[0] + p[0], encoder_center[1] + p[1], z])
            cylinder(h=pin_h + overlap, d=pin_d, center=true);
    }
}

module rotary_encoder_breakout() {
    union() {
        // PCB with holes cut out
        difference() {
            pcb_solid();
            mounting_holes_cut();
            header_holes_cut();
        }

        // Copper pads (top + bottom), connected via overlap into PCB
        header_pads_top();
        header_pads_bottom();

        // Encoder assembly (top only), connected via overlap into PCB
        encoder_body_top();

        // Encoder pin stubs (bottom), connected via overlap into PCB
        encoder_footprint_pins_bottom();
    }
}

rotary_encoder_breakout();