$fn = 64;

// Units: mm
board_w = 46.0;
board_h = 34.0;
board_t = 1.6;

corner_r = 2.0;

bezel_margin = 2.0;      // border around visible area
bezel_t = 2.2;           // thickness above PCB
bezel_overhang = 0.6;    // bezel extends beyond PCB outline slightly

glass_t = 1.0;
glass_inset = 0.4;       // inset from bezel inner opening

// Approximate visible area for 128x160 TFT (portrait), scaled to fit module
vis_w = 26.0;
vis_h = 35.0;

// Placement (centered)
vis_center_x = 0;
vis_center_y = 0;

// Simple connector footprint (approx) on one short edge
conn_w = 18.0;
conn_h = 6.0;
conn_t = 3.0;
conn_offset_y = -(board_h/2 - conn_h/2 - 1.0);

module rounded_rect_2d(w, h, r) {
    r2 = min(r, min(w, h)/2);
    hull() {
        translate([ w/2 - r2,  h/2 - r2]) circle(r=r2);
        translate([-w/2 + r2,  h/2 - r2]) circle(r=r2);
        translate([ w/2 - r2, -h/2 + r2]) circle(r=r2);
        translate([-w/2 + r2, -h/2 + r2]) circle(r=r2);
    }
}

module pcb() {
    color([0.05, 0.35, 0.12])
    linear_extrude(height=board_t)
        rounded_rect_2d(board_w, board_h, corner_r);
}

module bezel() {
    outer_w = board_w + 2*bezel_overhang;
    outer_h = board_h + 2*bezel_overhang;

    inner_w = vis_w + 2*bezel_margin;
    inner_h = vis_h + 2*bezel_margin;

    color([0.08, 0.08, 0.08])
    translate([0,0,board_t])
    difference() {
        linear_extrude(height=bezel_t)
            rounded_rect_2d(outer_w, outer_h, corner_r + bezel_overhang);

        // Window opening
        translate([vis_center_x, vis_center_y, -0.1])
        linear_extrude(height=bezel_t + 0.2)
            rounded_rect_2d(inner_w, inner_h, 1.0);
    }
}

module glass() {
    inner_w = vis_w + 2*bezel_margin - 2*glass_inset;
    inner_h = vis_h + 2*bezel_margin - 2*glass_inset;

    color([0.15, 0.25, 0.35, 0.35])
    translate([vis_center_x, vis_center_y, board_t + 0.2])
    linear_extrude(height=glass_t)
        rounded_rect_2d(inner_w, inner_h, 0.8);
}

module display_active_area() {
    color([0.02, 0.02, 0.02])
    translate([vis_center_x, vis_center_y, board_t + 0.25])
    linear_extrude(height=0.2)
        rounded_rect_2d(vis_w, vis_h, 0.6);
}

module connector() {
    color([0.85, 0.75, 0.25])
    translate([0, conn_offset_y, board_t])
    linear_extrude(height=conn_t)
        rounded_rect_2d(conn_w, conn_h, 0.8);
}

module mounting_holes() {
    hole_d = 2.4;
    inset = 3.0;
    for (sx = [-1, 1], sy = [-1, 1]) {
        translate([sx*(board_w/2 - inset), sy*(board_h/2 - inset), -0.1])
            cylinder(d=hole_d, h=board_t + bezel_t + 2.0);
    }
}

difference() {
    union() {
        pcb();
        bezel();
        glass();
        display_active_area();
        connector();
    }
    mounting_holes();
}