// LCD 2004A-style display module (single connected solid)
// Overall PCB: 97.0mm x 39.5mm

$fn = 64;

// -------------------- Parameters --------------------
pcb_L = 97.0;
pcb_W = 39.5;
pcb_T = 1.6;

corner_r = 2.0;

hole_d = 3.2;
hole_edge_margin_x = 3.5;
hole_edge_margin_y = 3.5;

window_L = 76.0;
window_W = 25.0;
window_offset_x = 0.0;
window_offset_y = 0.0;

// Bezel / front frame
bezel_T = 6.0;
bezel_margin_x = 6.0;
bezel_margin_y = 4.0;

// LCD glass / active area (raised detail)
glass_T = 2.2;
glass_margin = 2.0; // glass smaller than bezel opening

// Header pins (represented as a single connected block + pins)
pin_count = 16;
pin_pitch = 2.54;
pin_row_offset_x = 0.0;
pin_row_offset_y = -14.0;

header_body_L = (pin_count - 1) * pin_pitch + 2.54; // slight end margin
header_body_W = 5.0;
header_body_T = 2.5;

pin_w = 0.7;
pin_h = 6.0; // above header body
pin_embed = 1.2; // embed into header body for connectivity

// Backside controller "blob" (simple IC block)
ic_L = 40.0;
ic_W = 14.0;
ic_T = 2.8;
ic_offset_x = 0.0;
ic_offset_y = 10.0;

// Small overlap to guarantee unions are watertight
overlap = 0.4;

// -------------------- Helpers --------------------
module rounded_rect_prism(L, W, T, r) {
    // Minkowski rounded rectangle prism
    // Keep r sane
    rr = min(r, min(L, W)/2 - 0.01);
    minkowski() {
        cube([L - 2*rr, W - 2*rr, T], center=true);
        cylinder(r=rr, h=0.01, center=true);
    }
}

module mount_holes() {
    for (sx = [-1, 1], sy = [-1, 1]) {
        translate([sx*(pcb_L/2 - hole_edge_margin_x), sy*(pcb_W/2 - hole_edge_margin_y), 0])
            cylinder(d=hole_d, h=pcb_T + 2*overlap, center=true);
    }
}

module bezel_frame() {
    // Frame sits on top of PCB and is connected with slight overlap
    zc = pcb_T/2 + bezel_T/2 - overlap;
    translate([window_offset_x, window_offset_y, zc])
    difference() {
        cube([window_L + 2*bezel_margin_x, window_W + 2*bezel_margin_y, bezel_T], center=true);
        // Opening
        translate([0, 0, 0])
            cube([window_L, window_W, bezel_T + 2*overlap], center=true);
    }
}

module lcd_glass() {
    // Glass sits inside bezel opening, slightly raised, connected to bezel via overlap
    glass_L = window_L - 2*glass_margin;
    glass_W = window_W - 2*glass_margin;
    zc = pcb_T/2 + bezel_T - glass_T/2 - overlap; // overlaps into bezel
    translate([window_offset_x, window_offset_y, zc])
        cube([glass_L, glass_W, glass_T], center=true);
}

module header_body() {
    // Header body on top side of PCB near bottom edge
    zc = pcb_T/2 + header_body_T/2 - overlap;
    translate([pin_row_offset_x, pin_row_offset_y, zc])
        cube([header_body_L, header_body_W, header_body_T], center=true);
}

module header_pins() {
    // Pins protrude upward from header body; embedded for connectivity
    zc = pcb_T/2 + header_body_T - pin_h/2 + pin_embed - overlap;
    for (i = [0:pin_count-1]) {
        x = pin_row_offset_x - (pin_count-1)*pin_pitch/2 + i*pin_pitch;
        translate([x, pin_row_offset_y, zc])
            cube([pin_w, pin_w, pin_h], center=true);
    }
}

module backside_ic() {
    // Simple IC block on back side, connected to PCB with overlap
    zc = -pcb_T/2 - ic_T/2 + overlap;
    translate([ic_offset_x, ic_offset_y, zc])
        cube([ic_L, ic_W, ic_T], center=true);
}

// -------------------- Main Solid --------------------
module lcd2004a_module() {
    difference() {
        union() {
            // PCB (rounded corners)
            rounded_rect_prism(pcb_L, pcb_W, pcb_T, corner_r);

            // Bezel + glass (front details)
            bezel_frame();
            lcd_glass();

            // Header (body + pins)
            header_body();
            header_pins();

            // Backside controller block
            backside_ic();
        }

        // Mounting holes through PCB only (do not cut bezel/header)
        // Limit cut height to PCB thickness by centering at z=0
        mount_holes();
    }
}

lcd2004a_module();