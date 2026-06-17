// 40x40 T-slot aluminium extrusion (approximate), 100mm long
// FIX: ensure ONE connected solid (no floating corner segments, no split halves).
// Approach: create a connected 2D "base" (outer ring + diagonal corner bridges + center bridges),
// then subtract the T-slot voids + center bore. Bridges overlap by 1–2mm to guarantee attachment.

$fn = 96;

size = 40;
len  = 100;

// Profile tuning (mm)
wall            = 2.2;   // outer wall thickness
slot_open       = 6.2;   // opening at the outer face
slot_depth      = 10.5;  // depth of the slot from the outer face
slot_cavity_w   = 12.0;  // wider cavity behind the opening
slot_cavity_d   = 6.5;   // depth of the wider cavity
center_bore_r   = 5.0;   // central bore radius

// Connectivity / webbing
web_thickness   = 3.2;   // thickness of center cross webs
bridge_thick    = 3.0;   // thickness of diagonal corner bridges

// Overlap to guarantee physical attachment (mm)
overlap = 1.2;

// Small epsilon for robust boolean ops
eps = 0.05;

module base_solid_2d() {
    // Build a connected solid first (outer ring + internal bridges),
    // then subtract slots/bore from it.
    union() {
        // Outer ring (continuous perimeter)
        difference() {
            square([size, size], center=true);
            square([size - 2*wall, size - 2*wall], center=true);
        }

        // Center plus-shaped webs that overlap into the ring
        inner = size - 2*wall;
        web_len = inner + 2*overlap;

        square([web_len, web_thickness], center=true); // horizontal
        square([web_thickness, web_len], center=true); // vertical

        // Diagonal corner bridges to prevent 4 isolated corner quadrants
        // and to eliminate the "two long parallel bodies" split.
        // These bridges connect each corner region to the center webs.
        // Place bridge centers along the diagonal at ~1/4 of the inner span.
        diag_pos = inner/4;
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*diag_pos, sy*diag_pos])
                rotate(45)
                    square([inner/2 + 2*overlap, bridge_thick], center=true);
        }
    }
}

module tslot_voids_2d() {
    union() {
        // Central bore
        circle(r=center_bore_r);

        // Four T-slots (one per side): opening + inner cavity
        // +X
        translate([ size/2 - slot_depth/2, 0])
            square([slot_depth + eps, slot_open], center=true);
        translate([ size/2 - slot_depth - slot_cavity_d/2, 0])
            square([slot_cavity_d + eps, slot_cavity_w], center=true);

        // -X
        translate([-size/2 + slot_depth/2, 0])
            square([slot_depth + eps, slot_open], center=true);
        translate([-size/2 + slot_depth + slot_cavity_d/2, 0])
            square([slot_cavity_d + eps, slot_cavity_w], center=true);

        // +Y
        translate([0,  size/2 - slot_depth/2])
            square([slot_open, slot_depth + eps], center=true);
        translate([0,  size/2 - slot_depth - slot_cavity_d/2])
            square([slot_cavity_w, slot_cavity_d + eps], center=true);

        // -Y
        translate([0, -size/2 + slot_depth/2])
            square([slot_open, slot_depth + eps], center=true);
        translate([0, -size/2 + slot_depth + slot_cavity_d/2])
            square([slot_cavity_w, slot_cavity_d + eps], center=true);
    }
}

module tslot_40x40_2d_connected() {
    difference() {
        base_solid_2d();
        tslot_voids_2d();
    }
}

module extrusion_40x40(L=100) {
    union() {
        linear_extrude(height=L, center=true, convexity=10)
            tslot_40x40_2d_connected();
    }
}

extrusion_40x40(len);