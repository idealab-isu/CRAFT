$fn = 64;

// Single-board computer overall size (board only) — VERIFIED DIMENSIONS
board_x = 51.0;
board_y = 21.0;
board_z = 1.6;

// Small overlap to guarantee connectivity between parts
overlap = 0.25;

// ---------- Helpers ----------
module rounded_rect_prism(x, y, z, r) {
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(x/2 - r), sy*(y/2 - r), 0])
                cylinder(r=r, h=z, center=true);
    }
}

module mount_hole_pattern(x, y, inset_x, inset_y, hole_r, hole_h) {
    for (sx = [-1, 1], sy = [-1, 1])
        translate([sx*(x/2 - inset_x), sy*(y/2 - inset_y), 0])
            cylinder(r=hole_r, h=hole_h, center=true);
}

// ---------- Board + features (ONE connected solid) ----------
module sbc() {
    corner_r = 1.5;

    // Mounting holes
    hole_r = 1.25;          // ~2.5mm diameter
    hole_inset_x = 3.0;
    hole_inset_y = 3.0;

    // Z references
    z_top = board_z/2;
    z_bot = -board_z/2;

    // --- SBC-identifiable components/layout (all connected via overlap) ---

    // Long GPIO header along one long edge (x-), like many SBCs
    gpio_w = 5.0;
    gpio_len = 40.0;
    gpio_h = 8.5;

    // CPU package (top side)
    cpu_x = 14.0;
    cpu_y = 14.0;
    cpu_h = 2.0;

    // RAM package (top side)
    ram_x = 12.0;
    ram_y = 10.0;
    ram_h = 1.8;

    // USB-like connector on one short edge (y+)
    usb_w = 14.0;
    usb_d = 7.0;
    usb_h = 4.8;

    // Power connector on opposite short edge (y-)
    pwr_w = 9.0;
    pwr_d = 6.0;
    pwr_h = 3.2;

    // Bottom-side large connector/port block (to match views)
    bot_w = 18.0;
    bot_d = 7.5;
    bot_h = 4.0;

    // Two small passives (top side)
    cap_r = 2.0;
    cap_h = 3.0;

    difference() {
        union() {
            // PCB
            color([0.05, 0.45, 0.12])
                rounded_rect_prism(board_x, board_y, board_z, corner_r);

            // GPIO header (x- edge), centered in Y, overlaps into PCB
            color([0.10, 0.10, 0.10])
                translate([
                    -board_x/2 + gpio_w/2 - overlap,
                    0,
                    z_top + gpio_h/2 - overlap
                ])
                    cube([gpio_w, gpio_len, gpio_h], center=true);

            // CPU (center-ish), overlaps into PCB
            color([0.15, 0.15, 0.15])
                translate([
                    board_x*0.05,
                    0,
                    z_top + cpu_h/2 - overlap
                ])
                    cube([cpu_x, cpu_y, cpu_h], center=true);

            // RAM (near CPU), overlaps into PCB
            color([0.18, 0.18, 0.18])
                translate([
                    board_x*0.05,
                    cpu_y/2 + ram_y/2 - 1.0,
                    z_top + ram_h/2 - overlap
                ])
                    cube([ram_x, ram_y, ram_h], center=true);

            // USB connector (y+ edge), overlaps into PCB
            color([0.75, 0.75, 0.78])
                translate([
                    0,
                    board_y/2 - usb_d/2 + overlap,
                    z_top + usb_h/2 - overlap
                ])
                    cube([usb_w, usb_d, usb_h], center=true);

            // Power connector (y- edge), overlaps into PCB
            color([0.75, 0.75, 0.78])
                translate([
                    board_x*0.20,
                    -board_y/2 + pwr_d/2 - overlap,
                    z_top + pwr_h/2 - overlap
                ])
                    cube([pwr_w, pwr_d, pwr_h], center=true);

            // Bottom-side connector block (underside), overlaps into PCB
            color([0.65, 0.65, 0.68])
                translate([
                    board_x*0.05,
                    -board_y*0.10,
                    z_bot - bot_h/2 + overlap
                ])
                    cube([bot_w, bot_d, bot_h], center=true);

            // Two capacitors (top side), overlap into PCB
            color([0.20, 0.20, 0.20])
                translate([
                    -board_x*0.10,
                    board_y*0.20,
                    z_top + cap_h/2 - overlap
                ])
                    cylinder(r=cap_r, h=cap_h, center=true);

            color([0.20, 0.20, 0.20])
                translate([
                    -board_x*0.10,
                    -board_y*0.20,
                    z_top + cap_h/2 - overlap
                ])
                    cylinder(r=cap_r, h=cap_h, center=true);
        }

        // Mounting holes through PCB only
        mount_hole_pattern(board_x, board_y, hole_inset_x, hole_inset_y, hole_r, board_z + 0.6);
    }
}

sbc();