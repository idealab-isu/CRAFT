$fn = 64;

// Single-board computer overall size (PCB)
board_length = 85.0;
board_width  = 56.0;
board_thick  = 1.4;

// Visual feature sizes (kept modest; all connected to PCB)
corner_r = 3.0;

// Mounting holes (typical SBC style) - cut through PCB
hole_d = 2.75;
hole_edge_x = 3.5;
hole_edge_y = 3.5;

// Component heights above PCB
overlap = 0.2; // ensures union connectivity

usb_w = 15.0;
usb_d = 16.0;
usb_h = 13.0;

eth_w = 16.0;
eth_d = 21.0;
eth_h = 14.0;

hdmi_w = 14.0;
hdmi_d = 11.0;
hdmi_h = 6.0;

audio_d = 8.0;
audio_h = 6.0;

gpio_w = 51.0;
gpio_d = 5.0;
gpio_h = 8.5;

soc_w = 14.0;
soc_d = 14.0;
soc_h = 2.0;

usb_micro_w = 8.0;
usb_micro_d = 6.0;
usb_micro_h = 3.0;

module rounded_board(l, w, t, r){
    // Rounded rectangle prism via hull of corner cylinders
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([ (l/2 - r)*sx, (w/2 - r)*sy, 0 ])
                cylinder(r=r, h=t, center=true);
    }
}

module mounting_holes(){
    for (sx = [-1, 1], sy = [-1, 1])
        translate([ (board_length/2 - hole_edge_x)*sx,
                    (board_width/2  - hole_edge_y)*sy,
                    0 ])
            cylinder(d=hole_d, h=board_thick + 0.6, center=true);
}

module add_component(size_xyz, pos_xy){
    // size_xyz = [x,y,z], pos_xy = [x,y] on PCB plane
    translate([pos_xy[0], pos_xy[1], board_thick/2 + size_xyz[2]/2 - overlap])
        cube(size_xyz, center=true);
}

module add_cyl_component(d, h, pos_xy){
    translate([pos_xy[0], pos_xy[1], board_thick/2 + h/2 - overlap])
        cylinder(d=d, h=h, center=true);
}

difference() {
    union() {
        // PCB centered at origin
        rounded_board(board_length, board_width, board_thick, corner_r);

        // Ports/connectors (all attached to top of PCB)
        // Two stacked USB blocks along +Y edge (right side)
        add_component([usb_w, usb_d, usb_h],
                      [ board_length/2 - usb_w/2 - 6.0,
                        board_width/2 - usb_d/2 ]);

        add_component([usb_w, usb_d, usb_h],
                      [ board_length/2 - usb_w/2 - 24.0,
                        board_width/2 - usb_d/2 ]);

        // Ethernet near +Y edge (left-ish)
        add_component([eth_w, eth_d, eth_h],
                      [ -board_length/2 + eth_w/2 + 10.0,
                        board_width/2 - eth_d/2 ]);

        // HDMI along -Y edge (center)
        add_component([hdmi_w, hdmi_d, hdmi_h],
                      [ 0,
                        -board_width/2 + hdmi_d/2 ]);

        // Micro USB power along -Y edge (right)
        add_component([usb_micro_w, usb_micro_d, usb_micro_h],
                      [ board_length/2 - usb_micro_w/2 - 10.0,
                        -board_width/2 + usb_micro_d/2 ]);

        // Audio jack along -Y edge (left)
        add_cyl_component(audio_d, audio_h,
                          [ -board_length/2 + audio_d/2 + 10.0,
                            -board_width/2 + audio_d/2 + 2.0 ]);

        // GPIO header along -X edge (upper-left area)
        add_component([gpio_w, gpio_d, gpio_h],
                      [ -board_length/2 + gpio_w/2 + 6.0,
                        board_width/2 - gpio_d/2 - 10.0 ]);

        // Main SoC inboard
        add_component([soc_w, soc_d, soc_h],
                      [ 8.0, 0.0 ]);
    }

    // Mounting holes through PCB only (do not cut components)
    // Achieved by limiting hole height to PCB thickness and centering at PCB midplane
    mounting_holes();
}