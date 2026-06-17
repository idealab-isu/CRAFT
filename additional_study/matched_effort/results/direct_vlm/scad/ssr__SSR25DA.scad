$fn = 64;

// Solid State Relay module (single connected solid), overall: 63 x 45 x 23 mm
module ssr_module(len=63.0, wid=45.0, ht=23.0, corner_r=2.0) {

    // --- Feature proportions (kept parametric, derived from overall dims) ---
    base_t      = ht * 0.22;                 // bottom base thickness
    body_t      = ht - base_t;               // upper body thickness

    // Slight step between base and body
    step_in     = min(1.2, min(len, wid) * 0.03);

    // Mounting ears (integrated into base)
    ear_w       = wid * 0.22;
    ear_len     = min(8.0, len * 0.14);
    ear_r       = min(2.0, corner_r);

    // Mounting hole bosses (solid rings; no through-holes to keep one solid)
    boss_r      = 3.2;
    boss_h      = base_t * 0.55;
    hole_r      = 1.8;                       // shallow recess radius
    hole_d      = boss_h * 0.65;             // shallow recess depth

    // Terminal blocks on top (two blocks)
    term_h      = ht * 0.22;
    term_w      = wid * 0.28;
    term_len    = len * 0.30;
    term_r      = 1.2;

    // Small raised ridges on terminal blocks (suggest screw clamps)
    ridge_h     = term_h * 0.35;
    ridge_w     = term_w * 0.18;
    ridge_len   = term_len * 0.70;

    // Label recess on top face (shallow)
    label_inset = 0.8;
    label_d     = min(0.8, body_t * 0.18);
    label_len   = len * 0.62;
    label_wid   = wid * 0.55;
    label_r     = 1.5;

    // Helper: rounded rectangle prism centered at origin
    module rrect_prism(l, w, h, r) {
        linear_extrude(height=h, center=true)
            offset(r=r)
                square([l - 2*r, w - 2*r], center=true);
    }

    // Helper: rounded rectangle 2D
    module rrect2d(l, w, r) {
        offset(r=r)
            square([l - 2*r, w - 2*r], center=true);
    }

    // Positions derived from dimensions (no arbitrary offsets)
    ear_x = len/2 + ear_len/2 - 0.6;         // overlap into base by 0.6mm
    boss_x = len/2 + ear_len - boss_r - 0.8; // keep boss within ear
    boss_y = wid/2 - ear_w/2;                // centered in ear width

    term_x = 0;
    term_y = wid/2 - term_w/2 - 1.2;         // near one long edge
    term_z = -ht/2 + base_t + body_t + term_h/2 - 0.6; // overlap into top by 0.6mm

    label_z = -ht/2 + base_t + body_t - label_d/2;     // cut into top surface

    difference() {
        union() {
            // Base (with ears)
            translate([0, 0, -ht/2 + base_t/2])
                union() {
                    rrect_prism(len, wid, base_t, corner_r);

                    // Ears on both ends (connected with overlap)
                    for (sx = [-1, 1]) {
                        translate([sx*ear_x, 0, 0])
                            rrect_prism(ear_len, ear_w, base_t, ear_r);

                        // Boss on each ear (solid ring with shallow recess later)
                        translate([sx*boss_x, sx*0 + boss_y, base_t/2 - boss_h/2 + 0.2])
                            cylinder(r=boss_r, h=boss_h, center=true);
                    }
                }

            // Upper body (slightly inset to create a step)
            translate([0, 0, -ht/2 + base_t + body_t/2])
                rrect_prism(len - 2*step_in, wid - 2*step_in, body_t, corner_r);

            // Terminal blocks (two) on top, connected with overlap
            for (sx = [-1, 1]) {
                translate([sx*(term_len/2 + 1.0), term_y, term_z])
                    rrect_prism(term_len, term_w, term_h, term_r);

                // Raised ridges on each terminal block (two ridges per block)
                for (ry = [-1, 1]) {
                    translate([sx*(term_len/2 + 1.0), term_y + ry*(term_w*0.22), term_z + term_h/2 - ridge_h/2 + 0.2])
                        rrect_prism(ridge_len, ridge_w, ridge_h, 0.6);
                }
            }
        }

        // Shallow "mounting hole" recesses on bosses (do not cut through)
        for (sx = [-1, 1]) {
            translate([sx*boss_x, boss_y, -ht/2 + base_t - hole_d/2 + 0.2])
                cylinder(r=hole_r, h=hole_d, center=true);
        }

        // Label recess on top face (no text)
        translate([0, 0, label_z])
            linear_extrude(height=label_d, center=true)
                rrect2d(label_len - 2*label_inset, label_wid - 2*label_inset, label_r);
    }
}

ssr_module();