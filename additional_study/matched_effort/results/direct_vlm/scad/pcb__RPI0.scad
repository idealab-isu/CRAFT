$fn = 64;

// Single-board computer overall size
board_x = 65.0;
board_y = 30.0;
board_z = 1.4;

corner_r = 2.0;

// Small overlap to guarantee connectivity between parts
overlap = 0.25;

// ---------- Helpers ----------
module rounded_board(x, y, z, r) {
    r2 = min(r, x/2, y/2);
    linear_extrude(height = z, center = true)
        offset(r = r2)
            square([x - 2*r2, y - 2*r2], center = true);
}

module rounded_cube(size=[10,10,10], r=1, center=true) {
    // Minkowski rounded box (kept modest for performance)
    sx = size[0]; sy = size[1]; sz = size[2];
    rr = min(r, sx/2, sy/2, sz/2);
    minkowski() {
        cube([sx-2*rr, sy-2*rr, sz-2*rr], center=center);
        sphere(r=rr);
    }
}

module standoff(d=4.0, h=2.2) {
    cylinder(d=d, h=h, center=true);
}

module hole(d=2.6, h=20) {
    cylinder(d=d, h=h, center=true);
}

// ---------- Feature dimensions (generic SBC-like) ----------
mount_edge_x = 3.5;
mount_edge_y = 3.5;
mount_hole_d = 2.6;

standoff_d = 4.2;
standoff_h = 2.0;

// Top-side components
soc_x = 18; soc_y = 18; soc_h = 1.6;
ram_x = 12; ram_y = 10; ram_h = 1.2;

usb_x = 14; usb_y = 13; usb_h = 7.0;     // side connector block
hdmi_x = 12; hdmi_y = 8;  hdmi_h = 4.0;   // side connector block
jack_x = 10; jack_y = 10; jack_h = 6.0;   // side connector block

header_x = 2.6; header_y = 26; header_h = 3.0; // long pin header block

// Bottom-side components
reg_x = 8; reg_y = 6; reg_h = 1.2;
cap_d = 5; cap_h = 3.0;

// ---------- Placement formulas ----------
board_top_z = board_z/2;
board_bot_z = -board_z/2;

// Mount hole positions (from edges)
hx = board_x/2 - mount_edge_x;
hy = board_y/2 - mount_edge_y;

// Side connector Y positions (kept inside board outline)
conn_margin_y = 2.0;
usb_yc  = -board_y/2 + conn_margin_y + usb_y/2;
hdmi_yc = 0;
jack_yc =  board_y/2 - conn_margin_y - jack_y/2;

// Side connector X positions (flush to right edge, with slight overlap into board)
usb_xc  = board_x/2 - usb_x/2 + overlap;
hdmi_xc = board_x/2 - hdmi_x/2 + overlap;
jack_xc = board_x/2 - jack_x/2 + overlap;

// Header near left edge
header_margin_x = 3.0;
header_xc = -board_x/2 + header_margin_x + header_x/2;

// Top components positions
soc_xc = -board_x/2 + 18;
soc_yc = 0;

ram_xc = soc_xc + soc_x/2 + ram_x/2 + 3;
ram_yc = 0;

// Bottom components positions
reg_xc = -board_x/2 + 16;
reg_yc = -board_y/2 + 9;

cap1_xc = board_x/2 - 18;
cap1_yc = -board_y/2 + 8;

cap2_xc = board_x/2 - 18;
cap2_yc =  board_y/2 - 8;

// ---------- Model ----------
difference() {
    union() {
        // PCB
        color([0.05, 0.45, 0.15])
            rounded_board(board_x, board_y, board_z, corner_r);

        // Standoffs around mounting holes (connected to PCB with overlap)
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*hx, sy*hy, board_top_z + standoff_h/2 - overlap])
                color([0.08, 0.55, 0.20])
                    standoff(d=standoff_d, h=standoff_h);
        }

        // Top-side ICs (connected to PCB)
        translate([soc_xc, soc_yc, board_top_z + soc_h/2 - overlap])
            color([0.12, 0.12, 0.12])
                rounded_cube([soc_x, soc_y, soc_h], r=0.8, center=true);

        translate([ram_xc, ram_yc, board_top_z + ram_h/2 - overlap])
            color([0.18, 0.18, 0.18])
                rounded_cube([ram_x, ram_y, ram_h], r=0.6, center=true);

        // Long header block (connected)
        translate([header_xc, 0, board_top_z + header_h/2 - overlap])
            color([0.10, 0.10, 0.10])
                rounded_cube([header_x, header_y, header_h], r=0.4, center=true);

        // Side connectors (connected to PCB by overlap into board)
        translate([usb_xc, usb_yc, board_top_z + usb_h/2 - overlap])
            color([0.75, 0.75, 0.75])
                rounded_cube([usb_x, usb_y, usb_h], r=0.8, center=true);

        translate([hdmi_xc, hdmi_yc, board_top_z + hdmi_h/2 - overlap])
            color([0.70, 0.70, 0.70])
                rounded_cube([hdmi_x, hdmi_y, hdmi_h], r=0.7, center=true);

        translate([jack_xc, jack_yc, board_top_z + jack_h/2 - overlap])
            color([0.05, 0.05, 0.05])
                rounded_cube([jack_x, jack_y, jack_h], r=1.0, center=true);

        // Bottom-side parts (connected)
        translate([reg_xc, reg_yc, board_bot_z - reg_h/2 + overlap])
            color([0.15, 0.15, 0.15])
                rounded_cube([reg_x, reg_y, reg_h], r=0.5, center=true);

        translate([cap1_xc, cap1_yc, board_bot_z - cap_h/2 + overlap])
            color([0.20, 0.20, 0.20])
                cylinder(d=cap_d, h=cap_h, center=true);

        translate([cap2_xc, cap2_yc, board_bot_z - cap_h/2 + overlap])
            color([0.20, 0.20, 0.20])
                cylinder(d=cap_d, h=cap_h, center=true);
    }

    // Mounting holes through entire assembly thickness
    for (sx = [-1, 1], sy = [-1, 1]) {
        translate([sx*hx, sy*hy, 0])
            hole(d=mount_hole_d, h=50);
    }
}