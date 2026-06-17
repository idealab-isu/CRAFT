// SMD package target size: [6.5, 3.5, 1.6] (L, W, H)
// One connected solid with recognizable side terminations.

$fn = 48;

// Overall dimensions
L = 6.5;
W = 3.5;
H = 1.6;

// Termination (metal end caps) - kept within overall L
term_len = 0.9;          // length of each end termination along L
term_inset = 0.05;       // small inset from the very end
term_drop = 0.25;        // how much termination wraps down the sides
term_top = 0.10;         // slight wrap onto top

// Body shaping
edge_r = 0.25;           // corner rounding radius (XY)
top_r  = 0.12;           // top edge rounding (Z)
overlap = 0.02;          // ensures unions overlap (watertight)

// Rounded box helper (rounded in XY, with slight Z rounding via minkowski)
module rounded_body(l, w, h, r_xy, r_z) {
    // Keep radii valid
    rxy = min(r_xy, min(l, w)/2 - 0.001);
    rz  = min(r_z, h/2 - 0.001);

    minkowski() {
        // Core box reduced by rounding amounts
        cube([l - 2*rxy, w - 2*rxy, h - 2*rz], center=true);
        // Rounded edges: cylinder gives XY rounding; sphere gives Z rounding
        // Use sphere for uniform rounding; small rz keeps it subtle.
        scale([1,1,rz/rxy])
            sphere(r=rxy);
    }
}

// Main SMD model
module smd_6p5x3p5x1p6() {
    union() {
        // Ceramic/plastic body
        rounded_body(L, W, H, edge_r, top_r);

        // End terminations (wrap down sides and slightly onto top)
        for (sx = [-1, 1]) {
            // Place termination centered near each end, fully within overall length.
            // Center position computed from dimensions (no arbitrary offsets).
            translate([sx * (L/2 - term_inset - term_len/2 + overlap), 0, 0])
                union() {
                    // Side wrap (covers full height, slightly thicker to ensure overlap)
                    cube([term_len + 2*overlap, W + 2*overlap, H - term_drop], center=true);

                    // Bottom wrap (a bit thicker at bottom to look like plated end)
                    translate([0, 0, -(H/2) + (term_drop/2) - overlap])
                        cube([term_len + 2*overlap, W + 2*overlap, term_drop + 2*overlap], center=true);

                    // Small top wrap
                    translate([0, 0, (H/2) - (term_top/2) + overlap])
                        cube([term_len + 2*overlap, W*0.85, term_top + 2*overlap], center=true);
                }
        }
    }
}

smd_6p5x3p5x1p6();