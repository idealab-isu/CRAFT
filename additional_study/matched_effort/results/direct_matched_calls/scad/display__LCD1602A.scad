$fn = 64;

// LCD 1602A Display Module (approx. 71.3mm x 24.3mm)
// Simple, renderable approximation: PCB + bezel + viewing window + 16-pin header

// ---------- Parameters ----------
pcb_len = 71.3;
pcb_wid = 24.3;
pcb_thk = 1.6;

corner_r = 1.2;

mount_hole_d = 3.2;
mount_hole_edge_x = 2.5;   // distance from left/right edge to hole center
mount_hole_edge_y = 2.0;   // distance from top/bottom edge to hole center

bezel_len = 64.5;
bezel_wid = 16.0;
bezel_thk = 3.2;
bezel_z = pcb_thk;

window_len = 56.0;
window_wid = 12.0;
window_depth = 1.6;

header_pins = 16;
pin_pitch = 2.54;
pin_d = 0.7;
pin_len = 6.0;

header_body_len = (header_pins - 1) * pin_pitch + 2.0;
header_body_wid = 3.0;
header_body_thk = 2.5;

// Place header near top edge (typical for 1602 modules)
header_margin_top = 2.0;
header_x0 = (pcb_len - (header_pins - 1) * pin_pitch) / 2;
header_y = pcb_wid - header_margin_top - header_body_wid;

// ---------- Helpers ----------
module rounded_rect_2d(l, w, r) {
    r2 = min(r, min(l, w)/2);
    hull() {
        translate([ r2,  r2]) circle(r=r2);
        translate([l-r2,  r2]) circle(r=r2);
        translate([ r2, w-r2]) circle(r=r2);
        translate([l-r2, w-r2]) circle(r=r2);
    }
}

module pcb() {
    difference() {
        linear_extrude(height=pcb_thk)
            rounded_rect_2d(pcb_len, pcb_wid, corner_r);

        // Mount holes (4)
        for (x = [mount_hole_edge_x, pcb_len - mount_hole_edge_x])
            for (y = [mount_hole_edge_y, pcb_wid - mount_hole_edge_y])
                translate([x, y, -0.1])
                    cylinder(d=mount_hole_d, h=pcb_thk + 0.2);
    }
}

module bezel_and_window() {
    // Bezel centered on PCB
    bx = (pcb_len - bezel_len)/2;
    by = (pcb_wid - bezel_wid)/2;

    wx = (pcb_len - window_len)/2;
    wy = (pcb_wid - window_wid)/2;

    difference() {
        translate([bx, by, bezel_z])
            linear_extrude(height=bezel_thk)
                rounded_rect_2d(bezel_len, bezel_wid, 1.0);

        // Viewing window recess/cut
        translate([wx, wy, bezel_z + bezel_thk - window_depth])
            cube([window_len, window_wid, window_depth + 0.2], center=false);
    }

    // Dark "glass" insert
    translate([wx, wy, bezel_z + bezel_thk - window_depth])
        color([0.05,0.08,0.08])
            cube([window_len, window_wid, window_depth], center=false);
}

module header_1x16() {
    // Plastic body
    translate([header_x0 - 1.0, header_y, pcb_thk])
        color([0.1,0.1,0.1])
            cube([header_body_len, header_body_wid, header_body_thk], center=false);

    // Pins
    for (i = [0:header_pins-1]) {
        px = header_x0 + i*pin_pitch;
        py = header_y + header_body_wid/2;
        translate([px, py, pcb_thk - pin_len])
            color([0.8,0.7,0.2])
                cylinder(d=pin_d, h=pin_len + header_body_thk);
    }
}

// ---------- Assembly ----------
color([0.0, 0.45, 0.0]) pcb();
color([0.85, 0.85, 0.85]) bezel_and_window();
header_1x16();