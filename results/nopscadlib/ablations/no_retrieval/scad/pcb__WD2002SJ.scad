$fn = 64;

// =====================
// DC-DC module (mm)
// Target PCB: 78.0 x 47.0 x 1.6
// =====================
pcb_L = 78.0;
pcb_W = 47.0;
pcb_T = 1.6;

corner_r = 3.0;

// Mounting holes (typical 4-corner)
hole_d = 3.2;
hole_edge_offset = 3.5;

// Connectivity / robustness
conn_overlap = 0.6;          // overlap to guarantee watertight unions
relief_depth = 0.25;         // shallow top relief (kept < pcb_T)

// Bottom standoffs (feet)
standoff_d = 6.0;
standoff_h = 6.0;

// Terminal blocks (top side, at left/right edges)
terminal_block_L = 10.0;
terminal_block_W = 9.0;
terminal_block_H = 12.0;

// Small pad thickness (top copper pads)
pad_T = 0.25;

// Major components (top side)
inductor_L = 18.0;
inductor_W = 18.0;
inductor_H = 10.0;

cap_d = 10.0;
cap_H = 12.0;

ic_L = 10.0;
ic_W = 10.0;
ic_H = 2.2;

res_L = 6.0;
res_W = 3.0;
res_H = 1.6;

// Heatsink (top side)
heatsink_base_L = 26.0;
heatsink_base_W = 18.0;
heatsink_base_T = 2.0;
fin_T = 1.2;
fin_H = 10.0;
fin_count = 6;

// Test points (top side)
testpoint_d = 2.0;
testpoint_H = 1.5;

// =====================
// Helpers
// =====================
module rounded_rect_prism(L, W, T, r) {
    linear_extrude(height=T, center=true)
        offset(r=r)
            square([L - 2*r, W - 2*r], center=true);
}

module pcb_body() {
    rounded_rect_prism(pcb_L, pcb_W, pcb_T, corner_r);
}

module mount_holes() {
    for (x = [-1, 1])
        for (y = [-1, 1])
            translate([x*(pcb_L/2 - hole_edge_offset),
                       y*(pcb_W/2 - hole_edge_offset),
                       0])
                cylinder(d=hole_d, h=pcb_T + 2, center=true);
}

module top_relief() {
    // shallow pockets on top surface only (do not cut through)
    pocket_L = terminal_block_L*0.9;
    pocket_W = terminal_block_W*0.9;

    for (sx = [-1, 1]) {
        translate([sx*(pcb_L/2 - terminal_block_L/2),
                   0,
                   pcb_T/2 - relief_depth/2 + conn_overlap])
            cube([pocket_L, pocket_W, relief_depth], center=true);
    }
}

module standoffs_bottom() {
    // Connected to PCB bottom with slight overlap into PCB
    for (x = [-1, 1])
        for (y = [-1, 1])
            translate([x*(pcb_L/2 - hole_edge_offset),
                       y*(pcb_W/2 - hole_edge_offset),
                       -pcb_T/2 - standoff_h/2 + conn_overlap])
                cylinder(d=standoff_d, h=standoff_h + 2*conn_overlap, center=true);
}

module terminal_blocks_top() {
    // Place blocks so their OUTER faces are flush with PCB edges (no side protrusion beyond 78x47 footprint)
    // Left block outer face at x = -pcb_L/2
    translate([-pcb_L/2 + terminal_block_L/2,
               0,
               pcb_T/2 + terminal_block_H/2 - conn_overlap])
        cube([terminal_block_L, terminal_block_W, terminal_block_H], center=true);

    // Right block outer face at x = +pcb_L/2
    translate([ pcb_L/2 - terminal_block_L/2,
               0,
               pcb_T/2 + terminal_block_H/2 - conn_overlap])
        cube([terminal_block_L, terminal_block_W, terminal_block_H], center=true);
}

module connector_pads_top() {
    // Pads near each terminal block, touching PCB top
    pad_L = terminal_block_L*0.55;
    pad_W = terminal_block_W*0.45;

    // Keep pads inside PCB outline and near the blocks
    x_pad = pcb_L/2 - terminal_block_L + pad_L/2;
    y_off = terminal_block_W*0.28;

    for (sx = [-1, 1]) {
        translate([sx*x_pad,
                   y_off,
                   pcb_T/2 + pad_T/2 - conn_overlap])
            cube([pad_L, pad_W, pad_T], center=true);

        translate([sx*x_pad,
                   -y_off,
                   pcb_T/2 + pad_T/2 - conn_overlap])
            cube([pad_L, pad_W, pad_T], center=true);
    }
}

module major_components_top() {
    // Inductor (center-left)
    translate([-pcb_L*0.12,
               0,
               pcb_T/2 + inductor_H/2 - conn_overlap])
        cube([inductor_L, inductor_W, inductor_H], center=true);

    // Electrolytic capacitor (center-right)
    translate([pcb_L*0.18,
               -pcb_W*0.12,
               pcb_T/2 + cap_H/2 - conn_overlap])
        cylinder(d=cap_d, h=cap_H, center=true);

    // IC (near heatsink area)
    translate([pcb_L*0.10,
               pcb_W*0.10,
               pcb_T/2 + ic_H/2 - conn_overlap])
        cube([ic_L, ic_W, ic_H], center=true);

    // A couple of small resistors (adds recognizable detail)
    for (i = [0:2]) {
        x0 = -pcb_L*0.02 + i*(res_L + 2.0);
        translate([x0,
                   pcb_W*0.22,
                   pcb_T/2 + res_H/2 - conn_overlap])
            cube([res_L, res_W, res_H], center=true);
    }
}

module heatsink_top() {
    // Heatsink base and fins, all connected to PCB top
    base_x = pcb_L*0.22;
    base_y = pcb_W*0.18;

    union() {
        // Base
        translate([base_x,
                   base_y,
                   pcb_T/2 + heatsink_base_T/2 - conn_overlap])
            cube([heatsink_base_L, heatsink_base_W, heatsink_base_T], center=true);

        // Fins along X direction, sitting on base
        fin_span = heatsink_base_L - fin_T;
        for (i = [0:fin_count-1]) {
            x_pos = base_x - heatsink_base_L/2 + fin_T/2 + (i/(fin_count-1))*fin_span;
            translate([x_pos,
                       base_y,
                       pcb_T/2 + heatsink_base_T + fin_H/2 - conn_overlap])
                cube([fin_T, heatsink_base_W, fin_H], center=true);
        }
    }
}

module test_points_top() {
    // Small posts near top edge
    for (i = [0:2]) {
        x_tp = -pcb_L*0.05 + i*(pcb_L*0.06);
        translate([x_tp,
                   pcb_W*0.30,
                   pcb_T/2 + testpoint_H/2 - conn_overlap])
            cylinder(d=testpoint_d, h=testpoint_H, center=true);
    }
}

// =====================
// Complete module (ONE connected solid)
// =====================
module complete_module() {
    union() {
        // PCB with holes and shallow top relief
        difference() {
            pcb_body();
            mount_holes();
            top_relief();
        }

        // Bottom standoffs (connected)
        standoffs_bottom();

        // Top-side parts (connected)
        terminal_blocks_top();
        connector_pads_top();
        major_components_top();
        heatsink_top();
        test_points_top();
    }
}

// Render
color([0.0, 0.4, 0.2]) complete_module();