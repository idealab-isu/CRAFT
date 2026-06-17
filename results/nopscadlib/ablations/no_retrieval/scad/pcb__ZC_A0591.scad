// Motor driver module (PCB assembly) 35.0 x 32.0 x 1.6 mm PCB
// One connected solid, no text. All placements are formula-based.

$fn = 64;

// --- Parameters ---
pcb_L = 35.0;
pcb_W = 32.0;
pcb_T = 1.6;

corner_R = 1.0;

hole_d = 3.0;
hole_edge_offset = 3.0;

overlap = 0.4;          // small overlap to guarantee connectivity
eps = 0.01;

// Feature sizes (generic motor driver module look)
pin_pitch = 2.54;
pin_count = 8;
pin_body_L = (pin_count-1)*pin_pitch + 3.0;  // header plastic length
pin_body_W = 5.0;
pin_body_H = 4.0;       // reduced so overall thickness reads closer to PCB

terminal_body_L = 10.2;
terminal_body_W = 8.2;
terminal_body_H = 4.2;  // reduced

ic_L = 12.0;
ic_W = 12.0;
ic_H = 1.2;             // reduced

heatsink_L = 14.0;
heatsink_W = 14.0;
heatsink_H = 2.0;       // reduced

standoff_d = 5.6;       // around mounting holes (keeps model connected even with holes)
standoff_H = 0.8;       // reduced so PCB thickness is visually dominant

// Side "tabs"/connectors to avoid looking like a plain plate (still one solid)
side_tab_L = 6.0;
side_tab_W = 10.0;
side_tab_H = 2.2;

// --- Helpers ---
module rounded_rect_2d(L, W, R) {
    offset(r=R)
        square([L-2*R, W-2*R], center=true);
}

module rounded_rect_prism(L, W, H, R) {
    linear_extrude(height=H, center=true)
        rounded_rect_2d(L, W, R);
}

module pcb_outline_with_notches_2d() {
    // Create a slightly "module-like" outline with small edge notches/tabs
    // while keeping overall max dimensions pcb_L x pcb_W.
    union() {
        rounded_rect_2d(pcb_L, pcb_W, corner_R);

        // Small centered tab on +Y edge (kept within pcb_W by subtracting later)
        // Actually add a small "step" on +Y and -Y by unioning rectangles that
        // are still within the bounding box.
        tab_w = pcb_L * 0.35;
        tab_h = pcb_W * 0.08;

        translate([0,  pcb_W/2 - tab_h/2]) square([tab_w, tab_h], center=true);
        translate([0, -pcb_W/2 + tab_h/2]) square([tab_w, tab_h], center=true);

        // Small side steps on +/-X edges
        step_w = pcb_L * 0.08;
        step_h = pcb_W * 0.35;
        translate([ pcb_L/2 - step_w/2, 0]) square([step_w, step_h], center=true);
        translate([-pcb_L/2 + step_w/2, 0]) square([step_w, step_h], center=true);
    }
}

module pcb_with_holes() {
    difference() {
        linear_extrude(height=pcb_T, center=true)
            pcb_outline_with_notches_2d();

        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*(pcb_L/2 - hole_edge_offset), sy*(pcb_W/2 - hole_edge_offset), 0])
                cylinder(d=hole_d, h=pcb_T + 2*overlap, center=true);
        }
    }
}

module mounting_standoffs() {
    // Thin rings around holes on top side to keep a single connected solid
    for (sx = [-1, 1], sy = [-1, 1]) {
        translate([sx*(pcb_L/2 - hole_edge_offset), sy*(pcb_W/2 - hole_edge_offset),
                   pcb_T/2 + standoff_H/2 - overlap])
            difference() {
                cylinder(d=standoff_d, h=standoff_H, center=true);
                cylinder(d=hole_d, h=standoff_H + 2*overlap, center=true);
            }
    }
}

module pin_header() {
    // Place along bottom edge (negative Y), on top of PCB
    y_pos = -pcb_W/2 + pin_body_W/2;
    translate([0, y_pos, pcb_T/2 + pin_body_H/2 - overlap])
        cube([pin_body_L, pin_body_W, pin_body_H], center=true);
}

module terminal_block() {
    // Place along top edge (positive Y), on top of PCB
    y_pos = pcb_W/2 - terminal_body_W/2;
    translate([0, y_pos, pcb_T/2 + terminal_body_H/2 - overlap])
        cube([terminal_body_L, terminal_body_W, terminal_body_H], center=true);
}

module driver_ic() {
    // Center IC on top of PCB
    translate([0, 0, pcb_T/2 + ic_H/2 - overlap])
        cube([ic_L, ic_W, ic_H], center=true);
}

module heatsink() {
    // Heatsink on top of IC, slightly overlapping to ensure connectivity
    translate([0, 0, pcb_T/2 + ic_H + heatsink_H/2 - 2*overlap])
        cube([heatsink_L, heatsink_W, heatsink_H], center=true);
}

module side_tabs() {
    // Two small side protrusions (like connectors/driver package edges), connected to PCB top
    // Positioned at +/-X edges, centered in Y.
    x_pos = pcb_L/2 - side_tab_L/2;
    z_pos = pcb_T/2 + side_tab_H/2 - overlap;

    translate([ x_pos, 0, z_pos])
        cube([side_tab_L, side_tab_W, side_tab_H], center=true);

    translate([-x_pos, 0, z_pos])
        cube([side_tab_L, side_tab_W, side_tab_H], center=true);
}

// --- Final connected solid ---
module motor_driver_module() {
    union() {
        pcb_with_holes();
        mounting_standoffs();
        pin_header();
        terminal_block();
        driver_ic();
        heatsink();
        side_tabs();
    }
}

color([0.0, 0.4, 0.2]) motor_driver_module();