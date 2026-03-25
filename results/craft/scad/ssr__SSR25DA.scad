// Solid State Relay module (single connected solid)
// Overall envelope: 63.0mm x 45.0mm x 23.0mm

length = 63;  // X
width  = 45;  // Y
height = 23;  // Z

$fn = 64;

module rbox(size=[10,10,10], r=2, center=true) {
    // Rounded box via hull of corner cylinders (fast, predictable)
    sx = size[0]; sy = size[1]; sz = size[2];
    rr = min(r, sx/2, sy/2);
    translate(center ? [0,0,0] : [sx/2, sy/2, sz/2])
        hull() {
            for (ix=[-1,1], iy=[-1,1])
                translate([ix*(sx/2-rr), iy*(sy/2-rr), 0])
                    cylinder(r=rr, h=sz, center=true);
        }
}

module ssr_module() {
    // Envelope split
    base_h = 3.0;
    body_h = height - base_h;

    // Corner radii
    base_r = 2.2;
    body_r = 2.6;

    // Top step (slight inset on top surface)
    top_step_h = 1.6;
    top_step_inset = 1.2; // inset on X and Y

    // Terminal blocks (two) on top near +Y
    term_w = 18;   // X
    term_d = 12;   // Y
    term_h = 6;    // Z
    term_gap = 6;  // gap between blocks along X
    term_y_margin = 2.0;

    // Screw bosses on terminal blocks
    boss_d = 5.2;
    boss_h = 2.2;

    // Mounting ears (integrated) on left/right ends, within envelope
    ear_w = 7.0;                 // X thickness of ear region
    ear_d = width - 6.0;         // Y span of ear region
    ear_h = base_h;              // same as base thickness
    ear_r = 2.0;

    // Mounting recesses (shallow) on bottom, aligned with ears
    hole_d = 4.2;
    hole_depth = 1.6;
    hole_x = length/2 - ear_w/2; // centered in ear region
    hole_y = width/2 - 7.0;

    // Side fins (heatsink suggestion) on both long sides (±Y), connected
    fin_t = 1.2;
    fin_h = body_h - 2.0;
    fin_len = length - 10.0;
    fin_count = 6;
    fin_z0 = -height/2 + base_h + fin_h/2 + 1.0; // connected into housing

    // Front face raised label pad (adds detail without subtracting)
    pad_t = 0.9;
    pad_w = length - 14.0;
    pad_h = body_h - 7.0;
    pad_z = -height/2 + base_h + body_h/2;

    // Derived placements (formula-based)
    term_y = width/2 - term_d/2 - term_y_margin;
    term_x_center_offset = (term_w/2 + term_gap/2);
    term_z = height/2 - term_h/2;

    difference() {
        union() {
            // Base (includes ears as part of base footprint)
            translate([0,0,-height/2 + base_h/2])
                rbox([length, width, base_h], r=base_r, center=true);

            // Main housing
            translate([0,0,-height/2 + base_h + body_h/2])
                rbox([length, width, body_h], r=body_r, center=true);

            // Top step (slightly inset plateau) to break up silhouette
            translate([0,0,height/2 - top_step_h/2])
                rbox([length - 2*top_step_inset, width - 2*top_step_inset, top_step_h],
                     r=max(0.8, body_r-0.8), center=true);

            // Front face pad (+Y face)
            translate([0, width/2 - pad_t/2, pad_z])
                cube([pad_w, pad_t, pad_h], center=true);

            // Terminal blocks (two) on top near +Y
            for (sx = [-1, 1]) {
                translate([sx*term_x_center_offset, term_y, term_z])
                    rbox([term_w, term_d, term_h], r=1.2, center=true);

                // Two screw bosses per terminal block
                for (bx = [-1, 1]) {
                    translate([sx*term_x_center_offset + bx*(term_w*0.25), term_y, height/2 - boss_h/2])
                        cylinder(d=boss_d, h=boss_h, center=true);
                }
            }

            // Side fins on both ±Y sides (protrude slightly, but stay within envelope)
            // Place fins so their outer face is flush with width/2 (no envelope growth)
            for (side = [-1, 1]) {
                for (i = [0:fin_count-1]) {
                    x_pos = (-(fin_len/2) + i*(fin_len/(fin_count-1)));
                    translate([x_pos, side*(width/2 - fin_t/2), fin_z0])
                        cube([fin_len/fin_count*0.75, fin_t, fin_h], center=true);
                }
            }

            // Small cable/terminal lip at top front edge (+Y, +Z), connected
            lip_h = 1.4;
            lip_d = 2.2;
            lip_w = length - 8.0;
            translate([0, width/2 - lip_d/2, height/2 - top_step_h - lip_h/2])
                rbox([lip_w, lip_d, lip_h], r=0.8, center=true);
        }

        // Bottom mounting recesses (shallow dimples) - keep one connected solid
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*hole_x, sy*hole_y, -height/2 + hole_depth/2])
                cylinder(d=hole_d, h=hole_depth, center=true);
        }
    }
}

// Render
ssr_module();