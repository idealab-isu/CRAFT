$fn = 64;

// -------------------- Parameters (approx. Ruideng panel meter module) --------------------
bezel_w = 80;
bezel_h = 40;
bezel_t = 2.4;

bezel_lip = 1.2;          // front lip overhang around body
corner_r = 2.2;

body_w = 76;              // rear housing slightly smaller than bezel
body_h = 36;
body_d = 22;

display_w = 62;
display_h = 24;
display_inset = 0.9;      // recess depth into bezel

// Through window (so it doesn't look like a plain block)
window_w = 58;
window_h = 20;
window_r = 1.2;

button_d = 5.2;
button_h = 1.2;
button_spacing = 10.5;
button_y_from_bottom = 7.5;

tab_h = 10;
tab_t = 2.2;
tab_overhang = 2.0;       // how far tabs stick out from body sides

pcb_t = 1.6;
pcb_margin = 2.0;         // PCB smaller than body
pcb_z_gap = 1.0;          // gap from body back face to PCB

terminal_w = 12;
terminal_h = 8;
terminal_d = 6;
terminal_y_offset = 0;    // centered vertically on back
terminal_x_inset = 6;     // inset from body side

// Rear connector details (simple but recognizable)
conn_w = 10;
conn_h = 6;
conn_d = 4;
conn_x_inset = 8;
conn_y_offset = 0;

overlap = 0.6;            // small overlap to guarantee connectivity

// -------------------- Helpers --------------------
module rounded_rect_2d(w, h, r) {
    r2 = min(r, min(w, h)/2);
    hull() {
        translate([ w/2 - r2,  h/2 - r2]) circle(r=r2);
        translate([-w/2 + r2,  h/2 - r2]) circle(r=r2);
        translate([ w/2 - r2, -h/2 + r2]) circle(r=r2);
        translate([-w/2 + r2, -h/2 + r2]) circle(r=r2);
    }
}

module rounded_box(w, h, d, r) {
    linear_extrude(height=d, center=true)
        rounded_rect_2d(w, h, r);
}

// -------------------- Main model --------------------
module panel_meter() {

    // Coordinate system:
    // Front face of bezel at z = 0, model extends to negative z (rear).
    // Centered in X/Y.

    // Derived positions
    bezel_zc = -bezel_t/2;
    body_zc  = -(bezel_t + body_d)/2 + overlap/2;

    // Make ONE connected solid with real cutouts/details
    union() {

        // ---- Bezel + lip frame with display recess and through window ----
        translate([0, 0, bezel_zc])
        difference() {
            // Outer bezel (front face at z=0)
            rounded_box(bezel_w, bezel_h, bezel_t, corner_r);

            // Create a shallow recess pocket for the display area (not through)
            translate([0, 0, +bezel_t/2 - display_inset/2 + overlap/2])
                linear_extrude(height=display_inset + overlap, center=true)
                    rounded_rect_2d(display_w, display_h, 1.2);

            // Through window inside the recess (goes through bezel thickness)
            translate([0, 0, 0])
                linear_extrude(height=bezel_t + 2*overlap, center=true)
                    rounded_rect_2d(window_w, window_h, window_r);
        }

        // ---- Rear housing (connected to bezel) ----
        translate([0, 0, body_zc])
            rounded_box(body_w, body_h, body_d + overlap, 1.6);

        // ---- Side mounting tabs/clips (connected to housing) ----
        tab_zc = -(bezel_t + body_d/2); // mid-body
        tab_yc = 0;

        // Left tab
        translate([-(body_w/2 + tab_overhang/2 - overlap/2), tab_yc, tab_zc])
            rounded_box(tab_overhang + overlap, tab_h, tab_t, 0.8);

        // Right tab
        translate([+(body_w/2 + tab_overhang/2 - overlap/2), tab_yc, tab_zc])
            rounded_box(tab_overhang + overlap, tab_h, tab_t, 0.8);

        // ---- Front buttons (two small domes) ----
        btn_zc = -button_h/2 + overlap/2; // intersects bezel
        btn_yc = -bezel_h/2 + button_y_from_bottom;

        for (sx = [-1, 1]) {
            translate([sx * button_spacing/2, btn_yc, btn_zc])
                cylinder(h=button_h + overlap, d=button_d, center=true);
        }

        // ---- Rear PCB slab (connected inside housing) ----
        pcb_w = body_w - 2*pcb_margin;
        pcb_h = body_h - 2*pcb_margin;

        // Place PCB near back inner face, but still inside housing
        pcb_zc = -(bezel_t + body_d) + pcb_z_gap + pcb_t/2;
        translate([0, 0, pcb_zc])
            rounded_box(pcb_w, pcb_h, pcb_t + overlap, 0.8);

        // ---- Rear terminals (two blocks) attached to PCB/back area ----
        term_zc = pcb_zc - (pcb_t/2 + terminal_d/2 - overlap/2);
        term_yc = terminal_y_offset;

        translate([-(body_w/2 - terminal_x_inset - terminal_w/2), term_yc, term_zc])
            rounded_box(terminal_w, terminal_h, terminal_d + overlap, 0.8);

        translate([+(body_w/2 - terminal_x_inset - terminal_w/2), term_yc, term_zc])
            rounded_box(terminal_w, terminal_h, terminal_d + overlap, 0.8);

        // ---- Rear connector bumps (simple detailing) ----
        // Positioned slightly above terminals, still connected to PCB region.
        conn_zc = pcb_zc - (pcb_t/2 + conn_d/2 - overlap/2);
        conn_yc = conn_y_offset + (terminal_h/2 + conn_h/2 - overlap/2);

        translate([-(body_w/2 - conn_x_inset - conn_w/2), conn_yc, conn_zc])
            rounded_box(conn_w, conn_h, conn_d + overlap, 0.8);

        translate([+(body_w/2 - conn_x_inset - conn_w/2), conn_yc, conn_zc])
            rounded_box(conn_w, conn_h, conn_d + overlap, 0.8);
    }
}

panel_meter();