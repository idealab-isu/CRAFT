$fn = 96;

// PCB dimensions (mm)
pcb_length = 24.8;
pcb_width  = 14.6;
pcb_thick  = 1.0;

// Feature dimensions (mm)
corner_r   = 1.0;   // rounded board corners
hole_d     = 2.0;   // mounting holes
hole_edge  = 2.2;   // hole center offset from each edge

// Copper/silkscreen relief (engraved so model stays ONE connected solid)
copper_inset = 0.6;   // inset from board edge
copper_depth = 0.06;  // shallow engraving depth
silk_depth   = 0.03;  // even shallower engraving depth
eps = 0.01;

module rounded_rect_2d(L, W, r) {
    r2 = min(r, min(L, W)/2);
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(L/2 - r2), sy*(W/2 - r2)])
                circle(r = r2);
    }
}

module pcb_board(L, W, T, r) {
    linear_extrude(height = T, center = false)
        rounded_rect_2d(L, W, r);
}

module mounting_holes(L, W, T, d, edge) {
    for (sx = [-1, 1], sy = [-1, 1])
        translate([sx*(L/2 - edge), sy*(W/2 - edge), -eps])
            cylinder(h = T + 2*eps, d = d, center = false);
}

module copper_relief(L, W, T, inset, depth, r) {
    // Engrave a "copper area" on top surface
    translate([0, 0, T - depth])
        linear_extrude(height = depth + eps, center = false)
            rounded_rect_2d(L - 2*inset, W - 2*inset, max(0, r - inset));
}

module silkscreen_relief(L, W, T, depth) {
    // Simple silkscreen-like markings (engraved) on top surface
    // Border line
    border_in = 1.2;
    translate([0, 0, T - depth])
        linear_extrude(height = depth + eps, center = false)
            difference() {
                rounded_rect_2d(L - 2*border_in, W - 2*border_in, max(0, corner_r - border_in));
                rounded_rect_2d(L - 2*(border_in + 0.5), W - 2*(border_in + 0.5), max(0, corner_r - (border_in + 0.5)));
            }

    // A small "component outline" rectangle
    comp_L = L * 0.45;
    comp_W = W * 0.35;
    line_w = 0.5;
    translate([-(L/2) + (border_in + comp_L/2 + 1.0), 0, T - depth])
        linear_extrude(height = depth + eps, center = false)
            difference() {
                square([comp_L, comp_W], center = true);
                square([comp_L - 2*line_w, comp_W - 2*line_w], center = true);
            }
}

color([0.05, 0.45, 0.18])
translate([pcb_length/2, pcb_width/2, 0])  // keep original lower-left origin behavior
difference() {
    pcb_board(pcb_length, pcb_width, pcb_thick, corner_r);

    // Through holes
    mounting_holes(pcb_length, pcb_width, pcb_thick, hole_d, hole_edge);

    // Surface engravings (still one connected solid)
    copper_relief(pcb_length, pcb_width, pcb_thick, copper_inset, copper_depth, corner_r);
    silkscreen_relief(pcb_length, pcb_width, pcb_thick, silk_depth);
}