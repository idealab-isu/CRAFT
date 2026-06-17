// Rotary encoder breakout board PCB-only
// Target PCB: 26.3mm x 19.5mm x 1.6mm
// ONE connected solid (single PCB with through-holes)

$fn = 64;

// -------------------- Parameters --------------------
pcb_L = 26.3;
pcb_W = 19.5;
pcb_T = 1.6;

corner_R = 1.5;

// Mounting holes (4x)
mount_hole_d = 2.2;
mount_edge_offset = 3.0;

// Header holes (5x, 2.54mm pitch)
header_hole_d = 1.0;
header_pitch = 2.54;
header_pin_count = 5;

// Place header row along top edge (Y+), as in reference back view
header_row_edge_offset = 2.0;   // from top edge (Y+)
header_row_x_margin = 3.0;      // from left edge (X-)

// Small overlap to guarantee clean subtraction
overlap = 0.4;

// -------------------- Helpers --------------------
module rounded_rect_prism(L, W, H, R, center=true) {
    r = min(R, min(L, W)/2 - 0.01);
    minkowski() {
        cube([L - 2*r, W - 2*r, H], center=center);
        cylinder(r=r, h=0.01, center=true);
    }
}

module pcb_solid() {
    rounded_rect_prism(pcb_L, pcb_W, pcb_T, corner_R, center=true);
}

module mounting_holes() {
    for (sx = [-1, 1], sy = [-1, 1]) {
        translate([sx*(pcb_L/2 - mount_edge_offset),
                   sy*(pcb_W/2 - mount_edge_offset),
                   0])
            cylinder(d=mount_hole_d, h=pcb_T + 2*overlap, center=true);
    }
}

module header_holes() {
    // Along top edge (Y+), starting from left margin
    for (i = [0:header_pin_count-1]) {
        x = -pcb_L/2 + header_row_x_margin + i*header_pitch;
        y =  pcb_W/2 - header_row_edge_offset;
        translate([x, y, 0])
            cylinder(d=header_hole_d, h=pcb_T + 2*overlap, center=true);
    }
}

// -------------------- Final Model --------------------
module complete_model() {
    // Single connected solid: PCB with holes removed
    difference() {
        pcb_solid();
        mounting_holes();
        header_holes();
    }
}

color([0.0, 0.4, 0.2])
complete_model();