$fn = 64;

// Solid State Relay (SSR) module envelope: 63 x 45 x 23 (L x W x H)
L = 63;
W = 45;
H = 23;

eps = 0.25;          // small overlap for watertight unions/differences
ov  = 1.2;           // intentional structural overlap (1–2mm) between major parts

// -------------------- Feature sizing (kept within envelope) --------------------
base_t = 4;                 // mounting base thickness
body_h = 14;                // main housing height (above base)
term_h = H - base_t - body_h;

// Ensure positive and keep exact overall H
term_h = (term_h < 4) ? 4 : term_h;
body_h = H - base_t - term_h;

base_L = L;
base_W = W;

// Main housing footprint (typical SSR: smaller than base)
body_L = 52;
body_W = 38;

// Terminal blocks (two regions: output + input) on the same edge
term_W = 12;
term_L_out = 28;
term_L_in  = 18;
term_gap   = 2.0;           // gap between the two terminal regions

// Top lip/frame
lip_h = 1.2;
lip_t = 1.2;

chamfer = 1.2;

// Mounting holes (through base) - typical SSR: two holes along length
hole_d = 4.5;
hole_x_margin = 7;          // from ends along length
hole_y_offset = 0;          // centered in width

// Terminal screw bosses (shallow)
screw_d = 6;
screw_h = 2.2;
screw_pitch_out = 14;       // spacing between the two output screws
screw_pitch_in  = 10;       // spacing between the two input screws

// Heatsink-like ribs on underside (still one solid; no voids)
rib_count = 6;
rib_h = 1.6;
rib_w = 2.2;
rib_margin_x = 6;
rib_margin_y = 6;

// Recessed label plate (shallow pocket on top face of body)
label_recess_d = 0.8;
label_L = body_L * 0.72;
label_W = body_W * 0.62;

// -------------------- Derived positions (centered model) --------------------
z_base_c = -H/2 + base_t/2;

// Body overlaps into base by ov
z_body_c = z_base_c + (base_t/2 + body_h/2) - ov;

// Terminal blocks overlap into body by ov
z_term_c = z_body_c + (body_h/2 + term_h/2) - ov;

// Terminal blocks sit toward "front" (+Y) but within base width
front_margin = 2.0;
y_term_c = (base_W/2 - front_margin - term_W/2);

// -------------------- Helpers --------------------
module chamfer_cut_at_corner(xsign, ysign, zc, sx, sy, sz, c) {
    translate([xsign*(sx/2 - c/2), ysign*(sy/2 - c/2), zc])
        rotate([0,0,45])
            cube([c, c, sz + 2*eps], center=true);
}

module lip_frame(outerL, outerW, innerL, innerW, h, zc) {
    translate([0,0,zc])
    difference() {
        cube([outerL, outerW, h], center=true);
        cube([innerL, innerW, h + 2*eps], center=true);
    }
}

// -------------------- Parts --------------------
module base_with_holes_and_ribs() {
    difference() {
        union() {
            // Base plate
            translate([0,0,z_base_c])
                cube([base_L, base_W, base_t], center=true);

            // Underside ribs (attached to base bottom face with overlap)
            z_rib_c = (-H/2) + rib_h/2; // bottom of envelope
            rib_L = base_L - 2*rib_margin_x;
            rib_span_W = base_W - 2*rib_margin_y;

            for (i = [0:rib_count-1]) {
                y = -rib_span_W/2 + (i + 0.5) * (rib_span_W / rib_count);
                translate([0, y, z_rib_c + eps]) // eps overlap into base
                    cube([rib_L, rib_w, rib_h], center=true);
            }
        }

        // Two mounting holes along length, centered in width
        for (sx = [-1, 1]) {
            translate([sx*(base_L/2 - hole_x_margin), hole_y_offset, z_base_c])
                cylinder(h=base_t + 2*eps, r=hole_d/2, center=true);
        }
    }
}

module main_body_with_recess() {
    // Main housing block with chamfered vertical edges + shallow top recess
    difference() {
        // Outer body
        translate([0,0,z_body_c])
            cube([body_L, body_W, body_h], center=true);

        // Chamfer 4 vertical corners
        chamfer_cut_at_corner( 1, 1, z_body_c, body_L, body_W, body_h, chamfer);
        chamfer_cut_at_corner( 1,-1, z_body_c, body_L, body_W, body_h, chamfer);
        chamfer_cut_at_corner(-1, 1, z_body_c, body_L, body_W, body_h, chamfer);
        chamfer_cut_at_corner(-1,-1, z_body_c, body_L, body_W, body_h, chamfer);

        // Shallow recessed "label plate" on top face (no text)
        z_recess_c = z_body_c + body_h/2 - label_recess_d/2 + eps;
        translate([0, 0, z_recess_c])
            cube([label_L, label_W, label_recess_d + 2*eps], center=true);
    }

    // Top lip/frame (recognizable housing detail), attached to body top with overlap
    z_lip_c = z_body_c + body_h/2 - lip_h/2 + eps;
    lip_frame(body_L, body_W, body_L - 2*lip_t, body_W - 2*lip_t, lip_h, z_lip_c);
}

module terminal_blocks_with_screws() {
    // Two terminal block regions (output + input) on the same front edge.
    // Both overlap into the body by ov via z_term_c placement.
    union() {
        // Compute X positions so both blocks fit within body length and look like 2+2 terminals.
        side_margin = 3.0;
        usable_L = body_L - 2*side_margin;

        total_terms_L = term_L_out + term_gap + term_L_in;
        scale_k = (total_terms_L > usable_L) ? (usable_L / total_terms_L) : 1.0;

        tLo = term_L_out * scale_k;
        tLi = term_L_in  * scale_k;
        tGap = term_gap  * scale_k;

        // Place blocks so their combined span is centered on X
        // Left block = output, right block = input (simple, recognizable)
        x_out_c = -(tLi + tGap)/2;
        x_in_c  = +(tLo + tGap)/2;

        // Terminal blocks
        translate([x_out_c, y_term_c, z_term_c])
            cube([tLo, term_W, term_h], center=true);

        translate([x_in_c, y_term_c, z_term_c])
            cube([tLi, term_W, term_h], center=true);

        // Screw bosses on top of each terminal block (2 each = 4 total)
        z_screw_c = z_term_c + term_h/2 - screw_h/2 - eps;

        // Output screws (2)
        for (sx = [-1, 1]) {
            translate([x_out_c + sx*(screw_pitch_out/2)*scale_k, y_term_c, z_screw_c])
                cylinder(h=screw_h, r=screw_d/2, center=true);
        }

        // Input screws (2)
        for (sx = [-1, 1]) {
            translate([x_in_c + sx*(screw_pitch_in/2)*scale_k, y_term_c, z_screw_c])
                cylinder(h=screw_h, r=screw_d/2, center=true);
        }

        // Front "wire entry" ledge spanning both blocks (SSR-like silhouette)
        ledge_t = 1.6;
        ledge_h = term_h * 0.55;
        ledge_L = (tLo + tGap + tLi) * 0.98;

        // Attach to the FRONT face of the terminal blocks with overlap
        y_ledge_c = y_term_c + term_W/2 + ledge_t/2 - ov;
        z_ledge_c = z_term_c - term_h*0.05;

        translate([0, y_ledge_c, z_ledge_c])
            cube([ledge_L, ledge_t, ledge_h], center=true);
    }
}

// -------------------- Assembly (ONE connected solid) --------------------
module ssr_module() {
    union() {
        base_with_holes_and_ribs();
        main_body_with_recess();
        terminal_blocks_with_screws();

        // Blended transition between body and base (guaranteed connected via overlaps)
        pad_h = 1.2;
        pad_L = body_L * 0.85;
        pad_W = body_W * 0.85;

        // Recalculated to ensure the hull touches BOTH base and body with overlap
        z_pad_base_c = (z_base_c + base_t/2) - pad_h/2 + eps;     // slightly into base top
        z_pad_body_c = (z_body_c - body_h/2) + pad_h/2 - eps;     // slightly into body bottom

        hull() {
            translate([0,0,z_pad_base_c]) cube([pad_L, pad_W, pad_h], center=true);
            translate([0,0,z_pad_body_c]) cube([pad_L*0.96, pad_W*0.96, pad_h], center=true);
        }
    }
}

ssr_module();