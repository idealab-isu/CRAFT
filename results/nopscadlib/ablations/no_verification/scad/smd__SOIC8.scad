// Simple SMD package (single connected solid) sized exactly: [4.90, 3.90, 1.25]

// Dimensions (mm)
body_L = 4.90;
body_W = 3.90;
body_H = 1.25;

// Small cosmetic features (kept subtle; do not change overall size)
corner_r = 0.25;          // corner rounding radius
pin1_r   = 0.35;          // pin-1 dimple radius
pin1_d   = 0.12;          // pin-1 dimple depth (into top)
mark_L   = body_L/4;      // top marking pad size
mark_W   = body_W/4;
mark_h   = body_H/25;     // very thin raised pad
edge_m   = 0.55;          // pin-1 offset from edges
eps      = 0.02;          // small overlap to ensure watertight unions/differences

$fn = 48;

// Rounded-rectangle prism using hull of cylinders (robust, always visible)
module rounded_box(L, W, H, r) {
    r2 = min(r, min(L, W)/2 - 0.001);
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(L/2 - r2), sy*(W/2 - r2), 0])
                cylinder(h=H, r=r2, center=true);
    }
}

module smd() {
    union() {
        // Main body with pin-1 dimple and a small top pad marking
        difference() {
            rounded_box(body_L, body_W, body_H, corner_r);

            // Pin-1 dimple (subtracted from top surface)
            translate([
                -body_L/2 + edge_m,
                 body_W/2 - edge_m,
                 body_H/2 - pin1_d/2
            ])
                cylinder(h=pin1_d + 2*eps, r=pin1_r, center=true);
        }

        // Small raised top marking pad (kept within the top face)
        translate([0, 0, body_H/2 - mark_h/2])
            cube([mark_L, mark_W, mark_h], center=true);
    }
}

smd();