$fn = 64;

// Display module footprint (must be verifiable)
W = 46.0;   // X
H = 34.0;   // Y

// Thickness stack (Z)
pcb_t   = 1.6;
bezel_t = 2.4;   // above PCB
glass_t = 0.8;   // above bezel (slight)
back_t  = 2.0;   // below PCB (rear bulge max depth)

// Small overlap to guarantee manifold unions
ov = 0.25;

// Screen/window geometry (approx for 1.8" 128x160 module)
win_w = 34.0;
win_h = 26.0;
frame_r = 1.2;

// Bezel lip around window (keeps a recognizable frame)
bezel_lip = 2.0;

// Rear bulge (component area)
bulge_w = 30.0;
bulge_h = 22.0;

// Connector/FFC tail (kept connected to PCB)
tail_w = 16.0;
tail_len = 10.0;     // extends beyond PCB edge
tail_t = 0.8;        // thin flex
tail_step = 0.6;     // small stiffener thickness on tail near PCB

// Connector block on PCB underside near tail
conn_w = 18.0;
conn_h = 6.0;
conn_t = 2.6;

// Mounting holes (cut through PCB only, not bezel)
hole_r = 1.25;
hole_inset_x = 3.5;
hole_inset_y = 3.5;

// Small copper pad rings around holes (solid, connected)
pad_r = 2.2;
pad_t = 0.15;

// Simple rear components (solid bumps) to make back recognizable
chip1 = [10, 8, 1.2];
chip2 = [8, 6, 1.0];

// Helpers
module rounded_rect_2d(w, h, r) {
    r2 = min(r, min(w, h)/2);
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(w/2 - r2), sy*(h/2 - r2)])
                circle(r = r2);
    }
}

module display_module() {
    union() {

        // --- PCB with mounting holes (holes only through PCB thickness) ---
        difference() {
            // PCB spans Z: [0 .. pcb_t]
            linear_extrude(height = pcb_t)
                rounded_rect_2d(W, H, frame_r);

            // Mounting holes (through PCB only)
            for (sx = [-1, 1], sy = [-1, 1]) {
                translate([sx*(W/2 - hole_inset_x),
                           sy*(H/2 - hole_inset_y),
                           -ov])
                    cylinder(h = pcb_t + 2*ov, r = hole_r, center = false);
            }
        }

        // Copper pad rings around holes (thin, on top of PCB)
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*(W/2 - hole_inset_x),
                       sy*(H/2 - hole_inset_y),
                       pcb_t - ov])
                cylinder(h = pad_t + ov, r = pad_r, center = false);
        }

        // --- Front bezel/frame with window cutout (on top of PCB) ---
        translate([0, 0, pcb_t - ov])
        difference() {
            linear_extrude(height = bezel_t + ov)
                rounded_rect_2d(W, H, 1.0);

            // Window opening through bezel
            translate([0, 0, -ov])
                linear_extrude(height = bezel_t + 3*ov)
                    rounded_rect_2d(win_w, win_h, 0.8);
        }

        // --- Glass/active area (slightly raised, connected via overlap) ---
        glass_w = win_w - 2*bezel_lip;
        glass_h = win_h - 2*bezel_lip;
        translate([0, 0, pcb_t + bezel_t - ov])
            linear_extrude(height = glass_t + ov)
                rounded_rect_2d(glass_w, glass_h, 0.6);

        // --- Rear bulge (underside, connected to PCB) ---
        // Bulge spans Z: [-back_t .. 0]
        translate([0, 0, -back_t])
            linear_extrude(height = back_t + ov)
                rounded_rect_2d(bulge_w, bulge_h, 1.0);

        // --- Rear components (small bumps on underside, connected) ---
        // Place them within bulge area so they remain connected
        translate([-bulge_w*0.18, -bulge_h*0.10, -back_t + ov])
            cube([chip1[0], chip1[1], chip1[2]], center = false);

        translate([ bulge_w*0.10,  bulge_h*0.05, -back_t + ov])
            cube([chip2[0], chip2[1], chip2[2]], center = false);

        // --- Connector block on underside near +Y edge (connected) ---
        translate([0,
                   H/2 - conn_h/2 + ov,                 // touches PCB edge with overlap
                   -conn_t + ov])                        // sits under PCB (top at ~0)
            cube([conn_w, conn_h, conn_t], center = false);

        // --- FFC tail extending out of +Y edge (connected to PCB top) ---
        // Tail starts slightly inside PCB edge to ensure overlap, then extends outward.
        tail_y0 = H/2 - ov;                 // start at PCB edge with overlap
        translate([0, tail_y0, pcb_t - tail_t + ov])
            cube([tail_w, tail_len + ov, tail_t], center = false);

        // Small stiffener/strain relief on tail near PCB edge (connected)
        translate([0,
                   tail_y0 + ov,                           // begins at edge
                   pcb_t - tail_t + ov])
            cube([tail_w*0.9, (tail_len*0.45) + ov, tail_t + tail_step], center = false);
    }
}

display_module();