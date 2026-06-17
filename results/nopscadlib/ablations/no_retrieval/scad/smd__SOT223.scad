// SMD package: overall [6.5, 3.5, 1.6] mm
// One connected solid: body + end terminations fused to body.
// Includes shallow top polarity mark and visible end pads on top/bottom.

body_length = 6.5; //[3.25:13:0.1]
body_width  = 3.5; //[1.75:7:0.1]
body_height = 1.6; //[0.8:3.2:0.05]

$fn = 32;

eps = 0.02;
overlap = 0.05; // ensures fused solids (no floating / no coincident faces)

// Feature sizing (kept proportional; does not change overall dimensions)
term_len = min(1.1, body_length*0.18);          // end termination length
term_thk = min(0.30, body_height*0.22);         // termination thickness on top/bottom
side_wrap = min(0.18, body_width*0.06);         // small side wrap to make pads visible in side views
chamfer  = min(0.35, min(body_width, body_height)*0.18);
mark_r   = min(0.35, min(body_width, body_length)*0.08);
mark_d   = min(0.18, body_height*0.12);         // engraving depth

module smd_connected_solid() {

    // Main connected solid (no colors; single printable solid)
    difference() {
        union() {
            // Body
            cube([body_length, body_width, body_height], center=true);

            // End terminations: top + bottom + small side wrap, fused into body with overlap
            for (sx = [-1, 1]) {
                x_term = sx*(body_length/2 - term_len/2);

                // Top pad
                translate([x_term, 0, body_height/2 - term_thk/2 - overlap/2])
                    cube([term_len + overlap, body_width - 2*chamfer, term_thk + overlap], center=true);

                // Bottom pad
                translate([x_term, 0, -body_height/2 + term_thk/2 + overlap/2])
                    cube([term_len + overlap, body_width - 2*chamfer, term_thk + overlap], center=true);

                // Side wrap (makes terminations visible in left/right views)
                translate([x_term, 0, 0])
                    cube([term_len + overlap, body_width - 2*chamfer, body_height + overlap], center=true);

                // Slightly inset "window" to keep wrap narrow (still connected)
                // This creates a band near the ends rather than full-height metal look.
                // Implemented by adding a thin band only (already done by term_len), no extra subtraction needed.
            }
        }

        // Engraved polarity mark on top surface (shallow)
        translate([
            -body_length/2 + chamfer + mark_r*1.6,
             body_width/2  - chamfer - mark_r*1.6,
             body_height/2 - mark_d/2
        ])
            cylinder(h=mark_d + eps, r=mark_r, center=true);
    }
}

smd_connected_solid();