// 18.0mm x 18.0mm PCB, 0.8mm thick (single connected solid)
// All decorative layers are fused into the core so the result is ONE manifold solid.

$fn = 64;

// Parameters
pcb_L = 18.0;
pcb_W = 18.0;
pcb_T = 0.8;

corner_R = 1.0;

hole_d = 2.0;
hole_edge_margin = 3.0;

// Visual/relief details (kept small and FUSED into the core)
copper_relief = 0.03;   // raised copper detail (fused)
mask_relief   = 0.02;   // raised soldermask detail (fused)
silk_relief   = 0.01;   // raised silkscreen detail (fused)
layer_inset   = 0.25;   // inset from board edge for layers

// Robust overlap for boolean ops (small, dimension-derived)
eps = max(0.02, pcb_T/200);
cut_h = pcb_T + 2*eps;

// ---- Helpers ----
module rounded_rect_2d(L, W, R) {
    // Clamp radius to valid range
    r = min(R, min(L, W)/2 - eps);
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(L/2 - r), sy*(W/2 - r)]) circle(r=r);
    }
}

module pcb_core() {
    linear_extrude(height=pcb_T, center=true)
        rounded_rect_2d(pcb_L, pcb_W, corner_R);
}

module mount_holes() {
    for (sx = [-1, 1], sy = [-1, 1])
        translate([sx*(pcb_L/2 - hole_edge_margin),
                   sy*(pcb_W/2 - hole_edge_margin),
                   0])
            cylinder(d=hole_d, h=cut_h, center=true);
}

module top_relief(h, inset) {
    // Fused raised detail on top surface
    translate([0, 0, pcb_T/2 - eps + h/2])
        linear_extrude(height=h, center=true)
            rounded_rect_2d(pcb_L - 2*inset, pcb_W - 2*inset, max(corner_R - inset, 0.2));
}

module bottom_relief(h, inset) {
    // Fused raised detail on bottom surface
    translate([0, 0, -pcb_T/2 + eps - h/2])
        linear_extrude(height=h, center=true)
            rounded_rect_2d(pcb_L - 2*inset, pcb_W - 2*inset, max(corner_R - inset, 0.2));
}

// ---- Final: ONE connected solid ----
difference() {
    union() {
        // Core board
        pcb_core();

        // Fused surface details (kept subtle but visible)
        top_relief(mask_relief, layer_inset);
        bottom_relief(mask_relief, layer_inset);

        top_relief(copper_relief, layer_inset + 0.15);
        bottom_relief(copper_relief, layer_inset + 0.15);

        top_relief(silk_relief, layer_inset + 0.45);
        bottom_relief(silk_relief, layer_inset + 0.45);
    }

    // Through mounting holes
    mount_holes();
}