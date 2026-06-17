$fn = 96;

// Parameters (mm)
sheet_L = 100;                 // length
sheet_W = 100;                 // width
sheet_T = 7.94;                // ~5/16" = 7.9375mm
corner_r = 3;                  // outer corner fillet radius
edge_chamfer = 1.5;            // 45° chamfer size (inset from each edge)
hole_d = 6;                    // mounting hole diameter
hole_edge_offset = 12;         // hole center offset from each edge
overlap = 0.2;                 // small overlap for robust booleans

// Guardrails to avoid empty/invalid geometry
corner_r_eff = min(corner_r, min(sheet_L, sheet_W)/2 - overlap);
chamfer_eff  = min(edge_chamfer, min(sheet_L, sheet_W)/2 - overlap);
hole_off_x   = min(hole_edge_offset, sheet_L/2 - hole_d/2 - overlap);
hole_off_y   = min(hole_edge_offset, sheet_W/2 - hole_d/2 - overlap);

module rounded_rect_prism(L, W, T, R) {
    linear_extrude(height=T, center=true)
        offset(r=R)
            square([L - 2*R, W - 2*R], center=true);
}

module chamfer_cuts(L, W, T, c) {
    // Cut 45° chamfers at the four corners (top view)
    for (sx = [-1, 1], sy = [-1, 1]) {
        translate([sx*(L/2 - c), sy*(W/2 - c), 0])
            rotate([0, 0, 45])
                cube([2*c, 2*c, T + 2*overlap], center=true);
    }
}

module mounting_holes(L, W, T, d, offx, offy) {
    for (sx = [-1, 1], sy = [-1, 1]) {
        translate([sx*(L/2 - offx), sy*(W/2 - offy), 0])
            cylinder(d=d, h=T + 2*overlap, center=true);
    }
}

module complete_model() {
    difference() {
        rounded_rect_prism(sheet_L, sheet_W, sheet_T, corner_r_eff);
        chamfer_cuts(sheet_L, sheet_W, sheet_T, chamfer_eff);
        mounting_holes(sheet_L, sheet_W, sheet_T, hole_d, hole_off_x, hole_off_y);
    }
}

color("Silver") complete_model();